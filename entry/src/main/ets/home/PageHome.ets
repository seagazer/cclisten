import router from '@ohos.router';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { MediaController } from '../view/MediaController';
import { LyricController, LyricView } from '@seagazer/cclyric';
import { dimColor } from '../extensions/Extensions';
import { Logger } from '../extensions/Logger';
import { FileScanner } from '../extensions/FileScanner';
import { FileLyricParser } from '../player/FileLyricParser';
import { Song } from '../bean/Song';
import {
    APP_THEME,
    LiveData,
    MEDIA_SESSION_CURRENT_SONG,
    MEDIA_SESSION_FAVOURITE_LIST,
    MEDIA_SESSION_PLAYLIST
} from '../extensions/LiveData';
import { MediaSession } from '../player/MediaSession';
import { PlaylistManager } from '../playlist/PlaylistManager';
import { PlayHistoryManager } from '../history/PlayHistoryManager';
import { UIConfig } from '../config/UIConfig';
import { History } from '../bean/History';
import { LoopMode } from '../player/LoopMode';
import { AnimCoverView } from '../view/AnimCoverView';
import { MediaProgressView } from '../view/MediaProgressView';
import { TimerDialog } from '../view/TimerDialog';
import { DeleteDialog } from '../view/DeleteDialog';
import { SelectableImageButton } from '../view/SelectableImageButton';
import common from '@ohos.app.ability.common';
import { CountDownManager } from './CountDownManager';
import { PlaylistContainer } from '../view/PlaylistContainer';
import { MenuMoreButton } from '../view/MenuMoreButton';
import { LyricButton } from '../view/LyricButton';

const TAG = "[PageHome]"

@Entry
@Component
struct PageHome {
    @StorageLink(APP_THEME) @Watch("onThemeChanged") theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_CURRENT_SONG) @Watch("onSongChanged") currentSong: Song = new Song("", "", "", 0)
    @StorageLink(MEDIA_SESSION_PLAYLIST) playlist: Array<Song> = new Array()
    @StorageLink(MEDIA_SESSION_FAVOURITE_LIST) favouriteList: Array<Song> = new Array()
    @State currentPosition: number = 0
    @State isPlaying: boolean = false
    @State playingIndex: number = 0
    @Watch("onLoopModeChanged") @State loopMode: LoopMode = LoopMode.LOOP_ALL
    @State isShowLyric: boolean = false
    @State isShowPlaylist: boolean = false
    @State isNotPlayed: boolean = true
    @State deleteSong?: Song = undefined
    @State curTabIndex: number = 0
    @State isFavourite: boolean = false
    @State isCountDowning: boolean = false
    @State favouriteIcon: Resource = $r("app.media.ic_public_favor")
    @State timerIcon: Resource = $r("app.media.ic_public_clock")
    @State countDownText: string = ""
    private mediaSession: MediaSession = MediaSession.get()
    private historyManager: PlayHistoryManager = PlayHistoryManager.get()
    private playlistManager: PlaylistManager = PlaylistManager.get()
    private lyricController: LyricController = new LyricController()
    private lyricParser: FileLyricParser = new FileLyricParser()
    private countDownManager: CountDownManager = new CountDownManager((time) => {
        this.countDownText = time
    })
    private timerDialogController = new CustomDialogController({
        builder: TimerDialog({
            countDown: $countDownText,
            onAction: (minute) => {
                Logger.i(TAG, "count down minute= " + minute)
                if (minute > 0) {
                    this.timerIcon = $r("app.media.ic_public_clock_filled")
                    this.isCountDowning = true
                    this.countDownManager.startCountDownThread(getContext(this) as common.UIAbilityContext, minute)
                } else {
                    this.timerIcon = $r("app.media.ic_public_clock")
                    this.isCountDowning = false
                    this.countDownManager.stopCountDownThread()
                }
            }
        }),
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -32 }
    })
    private deleteDialogController = new CustomDialogController({
        builder: DeleteDialog({
            song: this.deleteSong,
            onAction: (song: Song) => {
                if (this.currentSong.url == song.url) {
                    this.playlistManager.setPlayingSong(null)
                    this.mediaSession.playNext()
                }
                this.playlistManager.remove(song)
                this.playingIndex = this.playlistManager.getPlayingIndex()
            }
        }),
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -32 }
    })

    aboutToAppear() {
        router.clear()
        let param = router.getParams() as Record<string, Object>
        Logger.d(TAG, "router param= " + JSON.stringify(param))
        if (param.song) { // app init play
            let song = param.song as Song
            if (song) {
                this.mediaSession.playSong(song)
                LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, song)
                this.isNotPlayed = false
            }
        } else if (param.history) { // app secondly play
            let history = param.history as History
            if (history) {
                Logger.d(TAG, "read history = " + JSON.stringify(history))
                this.loopMode = history.loopMode
                this.mediaSession.setLoopMode(history.loopMode)
                // the history song is not the same object as the song in playlist
                this.playingIndex = this.playlistManager.getIndex(history.song)
                let song = this.playlistManager.getSong(this.playingIndex)
                this.playlistManager.setPlayingSong(song)
            }
        }
        this.initPlayer()
    }

    private initPlayer() {
        this.mediaSession.initAvSession(getContext(this))
        this.mediaSession.onProgressChanged((position) => {
            this.currentPosition = position
            if (this.isShowLyric) {
                this.lyricController.updatePosition(this.currentPosition)
            }
        })
        this.mediaSession.onStateChanged((isPlaying: boolean) => {
            this.isPlaying = isPlaying
        })
        this.lyricController
            .setTextSize(vp2px(18))
            .setCacheSize(10)
            .setAnimationDuration(400)
            .setTextColor("#ccc1c1c1")
            .setHighlightColor(this.theme.colorPrimary)
            .setLineSpace(vp2px(16))
            .setHighlightStyle(false)
            .setEmptyHint("暂无歌词")
            .setLyric(null)
            .setAlignMode("center")
    }

    onThemeChanged() {
        this.lyricController.setHighlightColor(this.theme.colorPrimary)
        this.lyricController.updatePosition(this.currentPosition)
    }

    onBackPress() {
        if (this.isShowPlaylist) {
            this.isShowPlaylist = false
            return true
        }
        return false
    }

    @Builder
    MediaTitle() {
        Column() {
            Text(this.currentSong.title)
                .fontSize(UIConfig.FONT_TITLE)
                .fontColor(this.theme.colorPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.currentSong.artist)
                .fontSize(UIConfig.FONT_CONTENT)
                .fontColor(dimColor(this.theme.colorPrimary, 0.9))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 8 })
        }
    }

    private favourite() {
        this.currentSong.isFavourite = 1
        this.isFavourite = true
        this.favouriteIcon = $r("app.media.ic_public_favor_filled")
        this.playlistManager.setFavouriteState(this.currentSong, true)
    }

    private unFavourite() {
        this.currentSong.isFavourite = 0
        this.isFavourite = false
        this.favouriteIcon = $r("app.media.ic_public_favor")
        this.playlistManager.setFavouriteState(this.currentSong, false)
    }

    @Builder
    ActionContainer() {
        Row() {
            SelectableImageButton({ image: this.favouriteIcon, isSelected: this.isFavourite })
                .onClick(() => {
                    if (this.currentSong.isFavourite == 1) {
                        this.unFavourite()
                    } else {
                        this.favourite()
                    }
                })
            SelectableImageButton({ image: this.timerIcon, isSelected: this.isCountDowning })
                .onClick(() => {
                    this.timerDialogController.open()
                })
            LyricButton({ isShowLyric: $isShowLyric, isShowPlaylist: $isShowPlaylist, onAction: () => {
                this.lyricController.updatePosition(this.currentPosition)
            } })
            MenuMoreButton()
        }
        .width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 8, bottom: 12 })
    }

    @Builder
    CenterContainer() {
        Stack() {
            // cover
            Column() {
                AnimCoverView({
                    isAnim: this.isPlaying && !this.isShowLyric,
                    viewSize: 360,
                    animEdge: 64,
                    animDuration: 4000
                })
            }
            .width("100%")
            .height("100%")
            .justifyContent(FlexAlign.SpaceAround)
            .visibility(this.isShowLyric ? Visibility.Hidden : Visibility.Visible)

            // lyricView
            Column() {
                LyricView({ lyricController: this.lyricController })
            }
            .width("100%")
            .height("100%")
            .visibility(this.isShowLyric ? Visibility.Visible : Visibility.Hidden)
        }
        .width("100%")
        .layoutWeight(1)
    }

    build() {
        Stack() {
            Column() {
                // media title
                this.MediaTitle()
                // center
                this.CenterContainer()
                // actions buttons
                this.ActionContainer()
                // progress
                MediaProgressView({
                    currentSong: this.currentSong,
                    currentPosition: this.currentPosition,
                    onSeekChanged: (position: number) => {
                        this.mediaSession.seekTo(position)
                    }
                })
                // controller button
                MediaController({
                    isPlaying: this.isPlaying,
                    loopMode: this.loopMode,
                    actionPlay: () => {
                        if (this.isNotPlayed && this.currentSong) {
                            this.mediaSession.playSong(this.currentSong)
                            this.isNotPlayed = false
                            return
                        }
                        if (this.mediaSession.isPlaying()) {
                            this.mediaSession.pause()
                        } else {
                            this.mediaSession.start()
                        }
                    },
                    actionPlayNext: () => {
                        this.mediaSession.playNext()
                    },
                    actionPlayPre: () => {
                        this.mediaSession.playPre()
                    },
                    actionPlaylist: () => {
                        this.isShowPlaylist = true
                    }
                })
            }
            .width('100%')
            .height('100%')
            .padding(16)

            // playlist
            if (this.isShowPlaylist) {
                PlaylistContainer({
                    isShow: this.isShowPlaylist,
                    playingIndex: this.playingIndex,
                    onAction: (song: Song) => {
                        let realSong = this.playlistManager.getRealSong(song.url)
                        this.mediaSession.playSong(realSong)
                    },
                    onDelete: (song: Song) => {
                        let realSong = this.playlistManager.getRealSong(song.url)
                        this.deleteAction(realSong)
                    }
                })
            }
        }
        .alignContent(Alignment.Bottom)
        .width('100%')
        .height('100%')
    }

    private deleteAction(song: Song) {
        this.deleteSong = song
        this.deleteDialogController.open()
    }

    onSongChanged() {
        Logger.d(TAG, "onSongChanged= " + JSON.stringify(this.currentSong))
        this.playingIndex = this.playlistManager.getPlayingIndex()
        this.lyricController.setLyric(null)
        let filePath = FileScanner.scanLyricSync(getContext(this).filesDir, this.currentSong.title)
        Logger.d(TAG, "update lyric= " + filePath)
        if (filePath) {
            let lrc = this.lyricParser.parse(filePath)
            if (lrc) {
                this.lyricController.setLyric(lrc)
            }
        } else {
            Logger.e(TAG, "get lyric error!")
        }
        // save history when song changed, so the history is not loss if the app crash
        this.saveHistory()
        // refresh favourite ui
        if (this.currentSong.isFavourite == 1) {
            this.favouriteIcon = $r("app.media.ic_public_favor_filled")
            this.isFavourite = true
        } else {
            this.favouriteIcon = $r("app.media.ic_public_favor")
            this.isFavourite = false
        }
    }

    onLoopModeChanged() {
        this.mediaSession.setLoopMode(this.loopMode)
        this.playingIndex = this.playlistManager.getPlayingIndex()
    }

    aboutToDisappear() {
        this.saveHistory()
        this.countDownManager.stopCountDownThread()
    }

    private async saveHistory() {
        let history = new History(this.loopMode, this.currentSong)
        Logger.d(TAG, "save play history= " + JSON.stringify(history))
        await this.historyManager.saveHistory(history)
    }

    pageTransition() {
        PageTransitionEnter({ duration: 300 }).opacity(0).scale({ x: 0.75, y: 0.75 })
        PageTransitionExit({ duration: 300 }).opacity(0).scale({ x: 0.75, y: 0.75 })
    }
}