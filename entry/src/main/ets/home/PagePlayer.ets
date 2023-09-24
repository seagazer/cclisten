import { MediaController } from '../view/MediaController';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { LyricController, LyricView } from '@seagazer/cclyric';
import { duration2text as timeToString } from '../extensions/Extensions';
import { Logger } from '../extensions/Logger';
import { FileScanner } from '../extensions/FileScanner';
import { FileParser } from '../player/FileParser';
import { Song } from '../bean/Song';
import {
    APP_THEME,
    MEDIA_SESSION_CURRENT_SONG,
    MEDIA_SESSION_PLAYLIST,
    MEDIA_SESSION_PLAYING_STATE,
    MEDIA_SESSION_POSITION,
} from '../extensions/LiveData';
import { MediaSession } from '../player/MediaSession';
import common from '@ohos.app.ability.common';
import { ListItemView } from '../view/ListItemView';
import router from '@ohos.router';
import { PlaylistManager } from '../playlist/PlaylistManager';
import { MethodInvoker } from '../extensions/MethodInvoker';
import { PlayHistoryManager } from '../history/PlayHistoryManager';
import { UIConfig } from '../config/UIConfig';

const TAG = "[HomePlayer]"

@Component
export struct PagePlayer {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_POSITION) @Watch("onProgressChanged") currentPosition: number = 0
    @StorageLink(MEDIA_SESSION_CURRENT_SONG) @Watch("onSongChanged") currentSong: Song = null
    @StorageLink(MEDIA_SESSION_PLAYLIST) playlist: Array<Song> = new Array()
    @StorageLink(MEDIA_SESSION_PLAYING_STATE) isPlaying: boolean = false
    @State animAlpha: number = 1
    @State lyricLine: string = " "
    @State isShowLyric: boolean = false
    @State isShowPlaylist: boolean = false
    private context: common.Context
    private mediaSession: MediaSession = MediaSession.get()
    private lyricController: LyricController = new LyricController()
    private lyricParser: FileParser = new FileParser()
    private playlistScroller = new Scroller()
    private invoker: MethodInvoker
    @Prop isNotPlayed: boolean

    aboutToAppear() {
        router.clear()
        this.context = getContext(this)
        this.mediaSession.initAvSession(this.context)
        this.lyricController
            .setTextSize(vp2px(UIConfig.FONT_CONTENT))
            .setCacheSize(10)
            .setTextColor("#99343434")
            .setHighlightColor(this.theme.colorPrimary)
            .setLineSpace(vp2px(UIConfig.FONT_SUB_CONTENT))
            .setHighlightStyle(false)
            .setEmptyHint("暂无歌词")
            .setLyric(null)
            .setAlignMode("center")
        this.invoker?.registerContext(this)
        this.invoker?.registerMethod(this.backPress)
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

    @Builder
    ProgressView() {
        Column() {
            // slider
            Slider(
                {
                    style: SliderStyle.InSet,
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
                Text(timeToString(this.currentPosition))
                    .fontSize(UIConfig.FONT_CONTENT)
                    .fontColor(this.theme.colorSecondary)
                Text(timeToString(this.currentSong.duration))
                    .fontSize(UIConfig.FONT_CONTENT)
                    .fontColor(this.theme.colorSecondary)
            }.width('100%')
            .alignItems(VerticalAlign.Bottom)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 8, right: 8 })
        }
    }

    @Builder
    CoverView() {
        Column() {
            // cover image
            Image($r("app.media.ic_cover"))
                .objectFit(ImageFit.Cover)
                .width(320)
                .height(320)
                .padding(32)
                .backgroundColor(this.isPlaying ? "#ffbfbff1" : "#ffb7b7db")
                .border({ radius: UIConfig.DIMENSION_CORNER })
                .shadow({
                    radius: this.isPlaying ? UIConfig.DIMENSION_NORMAL_SHADOW : UIConfig.DIMENSION_PRESS_SHADOW,
                    offsetY: 12,
                    color: this.isPlaying ? "#b3dddddd" : "#b3989898"
                })
                .scale({ x: this.isPlaying ? 1 : 0.9, y: this.isPlaying ? 1 : 0.9 })
                .animation({
                    duration: 300
                })

            // media title
            Column() {
                Text(this.currentSong.title)
                    .fontSize(UIConfig.FONT_SUB_TITLE)
                    .fontColor(this.theme.colorPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(this.currentSong.artist)
                    .fontSize(UIConfig.FONT_CONTENT)
                    .fontColor(this.theme.colorSecondary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 8 })
            }.margin({ top: 16 })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.SpaceAround)
        .opacity(this.animAlpha)
        .animation({
            duration: 300
        })
        .onClick(() => {
            if (this.isShowPlaylist) {
                this.hidePlaylist()
                return
            }
            this.handleLyricVisible()
        })
    }

    @Builder
    LyricContainer() {
        Column() {
            LyricView({ lyricController: this.lyricController })
        }
        .width("100%")
        .height("100%")
        .padding(32)
        .opacity(1 - this.animAlpha)
        .animation({
            duration: 300,
            curve: Curve.Linear,
            delay: 0,
            iterations: 1,
            playMode: PlayMode.Normal
        })
        .onClick(() => {
            if (this.isShowPlaylist) {
                this.hidePlaylist()
                return
            }
            this.handleLyricVisible()
        })
    }

    backPress() {
        if (this.isShowPlaylist) {
            this.hidePlaylist()
            return true
        }
        return false
    }

    build() {
        Stack() {
            Column() {
                Stack() {
                    // cover
                    this.CoverView()
                    // lyricView
                    this.LyricContainer()
                }
                .width("100%")
                .layoutWeight(1)

                // progress
                this.ProgressView()
                // controller button
                MediaController({
                    actionPlayOrPause: this.playOrPause.bind(this),
                    actionPlayNext: () => {
                        this.mediaSession.playNext()
                    },
                    actionPlayPre: () => {
                        this.mediaSession.playPre()
                    },
                    onModeChanged: (mode) => {
                        this.mediaSession.setLoopMode(mode)
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
            ForEach(this.playlist, (song: Song, index) => {
                ListItem() {
                    if (song.title == this.currentSong.title) {
                        ListItemView({ data: song, index: index + 1, isHighLight: true })
                    } else {
                        ListItemView({ data: song, index: index + 1, isHighLight: false })
                    }
                }.onClick(() => {
                    this.mediaSession.playSong(song)
                    this.hidePlaylist()
                })
            })
        }
        .padding({ left: 16, right: 16, top: 32, bottom: 16 })
        .scrollBar(BarState.Auto)
        .width("90%")
        .height("60%")
        .margin({ bottom: 16 })
        .border({ radius: UIConfig.DIMENSION_CORNER })
        .backgroundColor("#fff7f7f7")
        .transition({ type: TransitionType.All, translate: { x: 0, y: "120%" } })
        .onAppear(() => {
            this.playlistScroller.scrollToIndex(PlaylistManager.get().getPlayingIndex())
        })
    }

    private onProgressChanged() {
        this.lyricController.updatePosition(this.currentPosition)
    }

    private onSongChanged() {
        Logger.d(TAG, "onSongChanged= " + JSON.stringify(this.currentSong))
        this.lyricLine = " "
        this.lyricController.setLyric(null)
        let filePath = FileScanner.scanLyricSync(this.context.filesDir, this.currentSong.title)
        Logger.d(TAG, "update lyric= " + filePath)
        if (filePath) {
            let lrc = this.lyricParser.parse(filePath)
            if (lrc) {
                this.lyricController.setLyric(lrc)
            }
        } else {
            Logger.e(TAG, "get lyric error!")
        }
        Logger.d(TAG, "save play history= " + JSON.stringify(this.currentSong))
        PlayHistoryManager.get().saveHistory(getContext(this), this.currentSong)
    }

    private async playOrPause() {
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

    private handleLyricVisible() {
        if (this.isShowPlaylist) {
            return
        }
        this.isShowLyric = !this.isShowLyric
        this.animAlpha = this.isShowLyric ? 0 : 1
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