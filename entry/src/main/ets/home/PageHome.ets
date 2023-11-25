import router from '@ohos.router';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { MediaController } from '../view/MediaController';
import { LyricController, LyricView } from '@seagazer/cclyric';
import { dimColor, duration2text } from '../extensions/Extensions';
import { Logger } from '../extensions/Logger';
import { FileScanner } from '../extensions/FileScanner';
import { FileLyricParser } from '../player/FileLyricParser';
import { Song } from '../bean/Song';
import {
    APP_THEME,
    MEDIA_SESSION_CURRENT_SONG,
    MEDIA_SESSION_PLAYLIST,
    MEDIA_SESSION_PLAYING_STATE,
    MEDIA_SESSION_POSITION,
    LiveData,
    MEDIA_SESSION_LOOP_MODE,
} from '../extensions/LiveData';
import { MediaSession } from '../player/MediaSession';
import { PlaylistItemView } from '../view/PlaylistItemView';
import { PlaylistManager } from '../playlist/PlaylistManager';
import { PlayHistoryManager } from '../history/PlayHistoryManager';
import { UIConfig } from '../config/UIConfig';
import { History } from '../bean/History';
import { LoopMode } from '../player/LoopMode';
import { AnimCoverView } from '../view/AnimCoverView';

const TAG = "[PageHome]"


@Entry
@Component
struct PageHome {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_POSITION) @Watch("onProgressChanged") currentPosition: number = 0
    @StorageLink(MEDIA_SESSION_CURRENT_SONG) @Watch("onSongChanged") currentSong: Song = new Song("", "", "", 0)
    @StorageLink(MEDIA_SESSION_PLAYLIST) playlist: Array<Song> = new Array()
    @StorageLink(MEDIA_SESSION_PLAYING_STATE) isPlaying: boolean = false
    @State @Watch("onLoopModeChanged") loopMode: LoopMode = LoopMode.LOOP_ALL
    @State coverAlpha: number = 1
    @State lyricLine: string = " "
    @State isShowLyric: boolean = false
    @State isShowPlaylist: boolean = false
    private mediaSession: MediaSession = MediaSession.get()
    private lyricController: LyricController = new LyricController()
    private lyricParser: FileLyricParser = new FileLyricParser()
    private playlistScroller = new Scroller()
    @State animAlpha: number = 1
    @State isNotPlayed: boolean = true

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
                this.loopMode = history.loopMode
                this.mediaSession.setLoopMode(history.loopMode)
                LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, history.song)
            }
        })
        this.mediaSession.initAvSession(getContext(this))
        this.lyricController
            .setTextSize(vp2px(18))
            .setCacheSize(10)
            .setAnimationDuration(500)
            .setTextColor("#98999A")
            .setHighlightColor(this.theme.colorPrimary)
            .setLineSpace(vp2px(16))
            .setHighlightStyle(false)
            .setEmptyHint("暂无歌词")
            .setLyric(null)
            .setAlignMode("center")
    }

    onBackPress() {
        if (this.isShowPlaylist) {
            this.hidePlaylist()
            return true
        }
        return false
    }

    @Builder
    CoverView() {
        Column() {
            // cover image
            AnimCoverView({
                isAnim: this.isPlaying && !this.isShowLyric,
                strokeColor: this.theme.colorPrimary,
                viewSize: 360,
                animEdge: 64
            }).onClick(() => {
                if (this.isShowPlaylist) {
                    this.hidePlaylist()
                    return
                }
                this.handleLyricVisible()
            })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.SpaceAround)
        // .opacity(this.coverAlpha)
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
        // .opacity(1 - this.coverAlpha)
        .animation({
            duration: 300,
        })
        .visibility(this.isShowLyric ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
            if (this.isShowPlaylist) {
                this.hidePlaylist()
                return
            }
            this.handleLyricVisible()
        })
    }

    @Builder
    ProgressView() {
        Column() {
            // slider
            Slider(
                {
                    style: SliderStyle.OutSet,
                    min: 0,
                    max: this.currentSong.duration,
                    value: this.currentPosition
                })
                .width('100%')
                .trackColor(this.theme.colorAction)
                .selectedColor(this.theme.colorPrimary)
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                        Logger.d(TAG, "seek to " + value + ", mode=" + mode + ", curPosition=" + this.currentPosition)
                        this.mediaSession.seekTo(value)
                    }
                })
            // duration
            Row() {
                Text(duration2text(this.currentPosition))
                    .fontSize(UIConfig.FONT_CONTENT)
                    .fontColor(this.theme.colorPrimary)
                Text(duration2text(this.currentSong.duration))
                    .fontSize(UIConfig.FONT_CONTENT)
                    .fontColor(this.theme.colorPrimary)
            }.width('100%')
            .alignItems(VerticalAlign.Bottom)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 8, right: 8 })
        }
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
                    this.CoverView()
                    // lyricView
                    this.LyricContainer()
                }
                .width("100%")
                .layoutWeight(1)

                // menu
                Row() {
                    Image($r("app.media.ic_public_text"))//lyric
                        .width(32).height(32)
                    Image($r("app.media.ic_public_favor"))//like
                        .width(32).height(32)
                    Image($r("app.media.ic_public_send"))//timer
                        .width(32).height(32)
                    Image($r("app.media.ic_public_storage"))//file
                        .width(32).height(32)
                    Image($r("app.media.ic_public_more"))//theme
                        .width(32).height(32)
                }.width("100%")
                .justifyContent(FlexAlign.SpaceBetween)
                .padding({ left: 6, right: 6, top: 16, bottom: 16 })

                // progress
                this.ProgressView()
                // controller button
                MediaController({
                    isPlaying: $isPlaying,
                    loopMode: $loopMode,
                    actionPlay: this.playOrPause,
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
                if (this.isShowPlaylist) {
                    this.hidePlaylist()
                }
            })

            // playlist
            if (this.isShowPlaylist) {
                this.Playlist()
            }
        }.alignContent(Alignment.Bottom)
        .width('100%')
        .height('100%')
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

    onProgressChanged() {
        this.lyricController.updatePosition(this.currentPosition)
    }

    onSongChanged() {
        Logger.d(TAG, "onSongChanged= " + JSON.stringify(this.currentSong))
        this.lyricLine = " "
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
    }

    onLoopModeChanged() {
        this.mediaSession.setLoopMode(this.loopMode)
    }

    private playOrPause = async () => {
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
    }

    @Styles
    pressedStyles() {
        .border({ radius: UIConfig.DIMENSION_CIRCLE })
        .backgroundColor(this.theme.colorAction)
    }

    @Styles
    normalStyles() {
        .border({ radius: UIConfig.DIMENSION_CIRCLE })
        .backgroundColor(null)
    }

    private handleLyricVisible() {
        if (this.isShowPlaylist) {
            return
        }
        this.isShowLyric = !this.isShowLyric
        this.coverAlpha = this.isShowLyric ? 0 : 1
    }

    private showPlaylist() {
        animateTo({ duration: 400, curve: Curve.FastOutSlowIn }, () => {
            this.isShowPlaylist = true
        })
    }

    private hidePlaylist() {
        animateTo({ duration: 400, curve: Curve.FastOutSlowIn }, () => {
            this.isShowPlaylist = false
        })
    }
}