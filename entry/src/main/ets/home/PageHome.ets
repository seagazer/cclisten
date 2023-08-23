import { MediaController } from '../view/MediaController';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { LyricController, LyricView } from '@seagazer/cclyric';
import { duration2text as timeToString } from '../extensions/Extensions';
import { Logger } from '../extensions/Logger';
import { FileScanner } from '../medialibrary/FileScanner';
import { FileParser } from '../player/FileParser';
import { Song } from '../bean/Song';
import {
    APP_THEME,
    MEDIA_SESSION_CURRENT_SONG,
    MEDIA_SESSION_FILE_LIST,
    MEDIA_SESSION_POSITION,
} from '../extensions/LiveData';
import { MediaSession } from '../player/MediaSession';
import common from '@ohos.app.ability.common';
import { ListItemView } from '../view/ListItemView';
import router from '@ohos.router';

const TAG = "[PageHome]"


// hdc file send C:\Users\seagazer\Desktop\画心.lrc /data/app/el2/100/base/com.seagazer.listen/haps/entry/files/

@Entry
@Component
struct PageHome {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_POSITION) @Watch("onProgressChanged") currentPosition: number = 0
    @StorageLink(MEDIA_SESSION_FILE_LIST) fileList: Array<Song> = new Array()
    @StorageLink(MEDIA_SESSION_CURRENT_SONG) @Watch("onSongChanged") currentSong: Song = null
    @State animAlpha: number = 1
    @State lyricLine: string = " "
    @State isShowLyric: boolean = false
    @State isShowPlaylist: boolean = false
    private context: common.Context
    private mediaSession: MediaSession = MediaSession.get()
    private lyricController: LyricController = new LyricController()
    private lyricParser: FileParser = new FileParser()
    private playlistScroller = new Scroller()

    aboutToAppear() {
        router.clear()
        this.context = getContext(this)
        this.lyricController
            .setTextSize(vp2px(16))
            .setCacheSize(4)
            .setTextColor(this.theme.colorSecondary)
            .setHighlightColor(this.theme.colorPrimary)
            .setLineSpace(vp2px(16))
            .setHighlightStyle(false)
            .setEmptyHint("暂无歌词")
            .setLyric(null)
            .setAlignMode("center")
        // @ts-ignore
        let song = router.getParams().data
        if (song) {
            Logger.d(TAG, "play from router= " + JSON.stringify(song))
            this.mediaSession.playSong(song as Song)
        }
    }

    @Styles
    pressedStyles() {
        .border({ radius: 200 })
        .backgroundColor(this.theme.colorAction)
    }

    @Styles
    normalStyles() {
        .border({ radius: 200 })
        .backgroundColor(null)
    }

    @Builder
    ProgressBar() {
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
                .trackColor(this.theme.colorPrimary)
                .blockColor(this.theme.colorPrimary)
                .selectedColor(this.theme.colorSecondary)
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                        Logger.d(TAG, "seek to " + value + ", mode=" + mode + ", curPosition=" + this.currentPosition)
                        this.mediaSession.seekTo(value)
                    }
                })
            // duration
            Row() {
                Text(timeToString(this.currentPosition)).fontSize(16).fontColor(this.theme.colorSecondary)
                Text(timeToString(this.currentSong.duration)).fontSize(16).fontColor(this.theme.colorSecondary)
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
                .backgroundColor("#ffbfbff1")
                .border({ radius: 8 })
                .shadow({ radius: 12, offsetY: 16, color: "#b3dddddd" })

            // media title
            Column() {
                Text(this.currentSong.title)
                    .fontSize(24)
                    .fontColor(this.theme.colorPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(this.currentSong.artist)
                    .fontSize(16)
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
            this.showHideLyric()
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
            iterations: 1, // 设置-1表示动画无限循环
            playMode: PlayMode.Normal
        })
        .onClick(() => {
            if (this.isShowPlaylist) {
                this.hidePlaylist()
                return
            }
            this.showHideLyric()
        })
    }

    onBackPress() {
        if (this.isShowPlaylist) {
            this.hidePlaylist()
            return true
        }
    }

    private tabController = new TabsController()

    @Builder
    TabMore() {
        Column() {
            Row() {
                Image($r("app.media.baseline_arrow_back_ios_24")).width(32).height(32)
                Text("关于").fontSize(16).margin({ left: 16 })
            }

            Row() {
                Image($r("app.media.baseline_arrow_back_ios_24")).width(32).height(32)
                Text("关于").fontSize(16).margin({ left: 16 })
            }.margin({ top: 4 })
        }
    }

    @Builder
    TabPlayer() {
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
                this.ProgressBar()
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
                        animateTo({ duration: 400, curve: Curve.FastOutSlowIn }, () => {
                            this.isShowPlaylist = true
                        })
                    }
                })
            }
            .width('100%')
            .height('100%')
            .padding({ left: 32, right: 32, top: 16, bottom: 16 })
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
    }

    @State currentId: number = 0

    @Builder
    Tab(id: number, title: string) {
        Text(title)
            .fontColor(this.currentId === id ? "#ff0000" : "#000000")
            .fontSize(16)
            .scale({ x: this.currentId === id ? 1.2 : 1, y: this.currentId === id ? 1.2 : 1 })
            .animation({
                duration: 250
            })
    }

    build() {
        Column() {
            Tabs({ controller: this.tabController }) {
                TabContent() {
                    Text("媒体库")
                }.tabBar(this.Tab(0, "媒体库"))

                TabContent() {
                    this.TabPlayer()
                }
                .tabBar(this.Tab(1, "首页"))

                TabContent() {
                    this.TabMore()
                }.tabBar(this.Tab(2, "更多"))
            }
            .barWidth(300)
            .barMode(BarMode.Fixed)
            .animationDuration(250)
            .onChange((index: number) => {
                this.currentId = index
            })
        }
        .width('100%')
        .height('100%')
    }

    @Builder
    Playlist() {
        List({ scroller: this.playlistScroller }) {
            ForEach(this.fileList, (song: Song, index) => {
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
        .onAppear(() => {
            for (let i = 0;i < this.fileList.length; i++) {
                let song = this.fileList[i]
                if (song.title == this.currentSong.title) {
                    this.playlistScroller.scrollToIndex(i)
                    break
                }
            }
        })
        .width("90%")
        .height("60%")
        .margin({ bottom: 16 })
        .border({ radius: 12 })
        .backgroundColor("#faf7f7f7")
        .transition({ type: TransitionType.All, translate: { x: 0, y: "120%" } })
    }

    private onProgressChanged() {
        Logger.d(TAG, "changed position ------------- ")
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
            lrc.lyricList.forEach((line) => {
                Logger.w(TAG, line.text)
            })
            if (lrc) {
                this.lyricController.setLyric(lrc)
            }
        } else {
            Logger.e(TAG, "get lyric error!")
        }
    }

    private async playOrPause() {
        if (this.mediaSession.isPlaying()) {
            this.mediaSession.pause()
        } else {
            this.mediaSession.start()
        }
    }

    private showHideLyric() {
        if (this.isShowPlaylist) {
            return
        }
        this.isShowLyric = !this.isShowLyric
        this.animAlpha = this.isShowLyric ? 0 : 1
    }

    private hidePlaylist() {
        animateTo({ duration: 400, curve: Curve.FastOutSlowIn }, () => {
            this.isShowPlaylist = false
        })
    }
}