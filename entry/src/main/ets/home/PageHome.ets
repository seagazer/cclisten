import router from '@ohos.router';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { MediaController } from '../view/MediaController';
import { LyricController, LyricView } from '@seagazer/cclyric';
import { dimColor, navigationTo, toast } from '../extensions/Extensions';
import { Logger } from '../extensions/Logger';
import { FileScanner } from '../extensions/FileScanner';
import { FileLyricParser } from '../player/FileLyricParser';
import { Song } from '../bean/Song';
import { APP_THEME, LiveData, MEDIA_SESSION_CURRENT_SONG, MEDIA_SESSION_PLAYLIST } from '../extensions/LiveData';
import { MediaSession } from '../player/MediaSession';
import { PlaylistItemView } from '../view/PlaylistItemView';
import { PlaylistManager } from '../playlist/PlaylistManager';
import { PlayHistoryManager } from '../history/PlayHistoryManager';
import { UIConfig } from '../config/UIConfig';
import { History } from '../bean/History';
import { LoopMode } from '../player/LoopMode';
import { AnimCoverView } from '../view/AnimCoverView';
import { MediaProgressView } from '../view/MediaProgressView';
import { StatefulImageButton } from '../view/StatefulImageButton';
import { StatelessImageButton } from '../view/StatelessImageButton';
import { TimerDialog } from '../view/TimerDialog';
import { PageRouter } from '../extensions/PageRouter';

const TAG = "[PageHome]"


@Entry
@Component
struct PageHome {
    @StorageLink(APP_THEME) @Watch("onThemeChanged") theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_CURRENT_SONG) @Watch("onSongChanged") currentSong: Song = new Song("", "", "", 0)
    @StorageLink(MEDIA_SESSION_PLAYLIST) playlist: Array<Song> = new Array()
    @State currentPosition: number = 0
    @State isPlaying: boolean = false
    @Watch("onLoopModeChanged") @State loopMode: LoopMode = LoopMode.LOOP_ALL
    @State isShowLyric: boolean = false
    @State isShowPlaylist: boolean = false
    @State isNotPlayed: boolean = true
    private mediaSession: MediaSession = MediaSession.get()
    private lyricController: LyricController = new LyricController()
    private lyricParser: FileLyricParser = new FileLyricParser()
    private playlistScroller = new Scroller()
    private dialogController = new CustomDialogController({
        builder: TimerDialog({
            onAction: (minute) => {
                if (minute > 0) {
                    this.timerIcon = $r("app.media.ic_public_clock_filled")
                } else {
                    this.timerIcon = $r("app.media.ic_public_clock")
                }
            }
        }),
        autoCancel: false,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -32 }
    })

    aboutToAppear() {
        router.clear()
        let param = router.getParams()
        if (param) {
            let song = param as Song
            if (song) {
                Logger.d(TAG, "play from router= " + JSON.stringify(song))
                this.mediaSession.playSong(song)
                LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, song)
                this.isNotPlayed = false
            }
        }
        PlayHistoryManager.get().readHistory(getContext(this)).then((history) => {
            if (history) {
                Logger.d(TAG, "read history = " + JSON.stringify(history))
                setTimeout(() => {
                    this.loopMode = history.loopMode
                }, 300)
                this.mediaSession.setLoopMode(history.loopMode)
                LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, history.song)
            }
        })
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
            .setTextColor("#e6acacac")
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
            this.hidePlaylist()
            return true
        }
        return false
    }

    @Builder
    MediaCoverView() {
        Column() {
            // cover image
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
        .animation({
            duration: 300
        })
        .visibility(this.isShowLyric ? Visibility.Hidden : Visibility.Visible)
    }

    @Builder
    LyricContainer() {
        Column() {
            LyricView({ lyricController: this.lyricController })
        }
        .width("100%")
        .height("100%")
        .padding(32)
        .animation({
            duration: 300,
        })
        .visibility(this.isShowLyric ? Visibility.Visible : Visibility.Hidden)
    }

    @Builder
    MoreMenu() {
        Column() {
            Row() {
                Image($r("app.media.app_icon")).width(20).height(20).margin({ right: 5 })
                Text("主题设置").fontSize(20)
            }
            .width('100%')
            .height(30)
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
                navigationTo(PageRouter.PAGE_SETTINGS_THEME)
            })

            Row() {
                Image($r("app.media.app_icon")).width(20).height(20).margin({ right: 5 })
                Text("媒体库").fontSize(20)
            }
            .width('100%')
            .height(30)
            .justifyContent(FlexAlign.Start)

            Row() {
                Image($r("app.media.app_icon")).width(20).height(20).margin({ right: 5 })
                Text("关于").fontSize(20)
            }
            .width('100%')
            .height(30)
            .justifyContent(FlexAlign.Start)
            .onClick(() => {
                navigationTo(PageRouter.PAGE_SETTINGS_ABOUT)
            })
        }
        .width(100)
        .padding(5)
    }

    @State favouriteIcon: Resource = $r("app.media.ic_public_favor")
    @State timerIcon: Resource = $r("app.media.ic_public_clock")
    @State lyricIcon: Resource = $r("app.media.ic_public_text")

    @Builder
    MenuContainer() {
        Row() {
            StatefulImageButton({ image: this.favouriteIcon })
                .onClick(() => {
                    if (this.currentSong.isFavourite == 1) {
                        this.currentSong.isFavourite = 0
                        this.favouriteIcon = $r("app.media.ic_public_favor")
                        PlaylistManager.get().updateSong(this.currentSong)
                    } else {
                        this.currentSong.isFavourite = 1
                        this.favouriteIcon = $r("app.media.ic_public_favor_filled")
                        PlaylistManager.get().updateSong(this.currentSong)
                    }
                })
            StatelessImageButton({ image: $r("app.media.ic_public_send") })
                .onClick(() => {
                    // todo distribute share
                    toast("TODO")
                })
            StatefulImageButton({ image: this.timerIcon })
                .onClick(() => {
                    this.dialogController.open()
                })
            StatefulImageButton({ image: this.lyricIcon })
                .onClick(() => {
                    if (this.isShowLyric) {
                        this.isShowLyric = false
                        this.lyricIcon = $r('app.media.ic_public_text')
                    } else {
                        if (this.isShowPlaylist) {
                            return
                        }
                        this.isShowLyric = true
                        this.lyricIcon = $r('app.media.ic_public_text_filled')
                    }
                })
            StatelessImageButton({ image: $r("app.media.ic_public_more") })
                .bindMenu(this.MoreMenu)
        }.width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ top: 8, bottom: 12 })
    }

    @Builder
    Playlist() {
        List({ scroller: this.playlistScroller }) {
            ForEach(this.playlist, (song: Song, _) => {
                ListItem() {
                    PlaylistItemView({ data: song, isHighLight: song.title == this.currentSong.title })
                }.onClick(() => {
                    this.mediaSession.playSong(song)
                    this.hidePlaylist()
                })
            })
        }
        .padding({ left: 16, right: 16, top: 32, bottom: 16 })
        .scrollBar(BarState.Auto)
        .width("100%")
        .height("60%")
        .border({ radius: 16 })
        .backgroundColor("#fff6f6f6")
        .transition({ type: TransitionType.All, translate: { x: 0, y: "120%" } })
        .onAppear(() => {
            this.playlistScroller.scrollToIndex(PlaylistManager.get().getPlayingIndex())
        })
    }

    build() {
        Stack() {
            Column() {
                // media title
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
                }.margin({ top: 16 })

                Stack() {
                    // cover
                    this.MediaCoverView()
                    // lyricView
                    this.LyricContainer()
                }
                .width("100%")
                .layoutWeight(1)

                // menu
                this.MenuContainer()

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
                        this.showPlaylist()
                    }
                })
            }
            .width('100%')
            .height('100%')
            .padding(16)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
                this.hidePlaylist()
            })

            // playlist
            if (this.isShowPlaylist) {
                this.Playlist()
            }
        }.alignContent(Alignment.Bottom)
        .width('100%')
        .height('100%')
    }

    onSongChanged() {
        Logger.d(TAG, "onSongChanged= " + JSON.stringify(this.currentSong))
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
        let history = new History(this.loopMode, this.currentSong)
        Logger.d(TAG, "save play history= " + JSON.stringify(history))
        PlayHistoryManager.get().saveHistory(getContext(this), history)
        // refresh favourite ui
        if (this.currentSong.isFavourite == 1) {
            this.favouriteIcon = $r("app.media.ic_public_favor_filled")
        } else {
            this.favouriteIcon = $r("app.media.ic_public_favor")
        }
    }

    onLoopModeChanged() {
        this.mediaSession.setLoopMode(this.loopMode)
    }

    private showPlaylist() {
        if (!this.isShowPlaylist) {
            animateTo({ duration: 400, curve: Curve.FastOutSlowIn }, () => {
                this.isShowPlaylist = true
            })
        }
    }

    private hidePlaylist() {
        if (this.isShowPlaylist) {
            animateTo({ duration: 400, curve: Curve.FastOutSlowIn }, () => {
                this.isShowPlaylist = false
            })
        }
    }
}