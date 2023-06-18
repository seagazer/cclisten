import { MediaController } from '../view/MediaController';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { Lyric, LyricConfig, LyricHelper, LyricView } from '@seagazer/cclyric';
import { duration2text as timeToString } from '../extensions/Extensions';
import { Logger } from '../extensions/Logger';
import { FileScanner } from '../medialibrary/FileScanner';
import { FileParser } from '../player/FileParser';
import { Song } from '../bean/Song';
import {
    APP_THEME,
    MEDIA_SESSION_ARTIST,
    MEDIA_SESSION_CURRENT_SONG,
    MEDIA_SESSION_DURATION,
    MEDIA_SESSION_FILE_LIST,
    MEDIA_SESSION_POSITION,
    MEDIA_SESSION_TITLE
} from '../extensions/LiveData';
import { MediaSession } from '../player/MediaSession';
import common from '@ohos.app.ability.common';

const TAG = "[PagePlay]"


// hdc file send C:\Users\seagazer\Desktop\画心.lrc /data/app/el2/100/base/com.seagazer.listen/haps/entry/files/

@Entry
@Component
struct PagePlay {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_TITLE) title: string = ""
    @StorageLink(MEDIA_SESSION_ARTIST) artist: string = ""
    @StorageLink(MEDIA_SESSION_POSITION) currentPosition: number = 0
    @StorageLink(MEDIA_SESSION_DURATION) totalDuration: number = 0
    @StorageLink(MEDIA_SESSION_FILE_LIST) fileList: Array<Song> = new Array()
    @State animAlpha: number = 1
    @State lyricLine: string = " "
    @State isShowLyric: boolean = false
    private context: common.Context
    private mediaSession: MediaSession = MediaSession.get()
    private lyricConfig: LyricConfig = new LyricConfig()
    private lyricHelper: LyricHelper = new LyricHelper()
    private lyricParser: FileParser = new FileParser()
    private lyricList = new Array<Lyric>()
    // todo
    private onProgressChanged = (position: number) => {
        this.lyricConfig.updatePosition(position)
        this.lyricLine = this.lyricHelper.getLyric(position)
    }
    private onSongChanged = async () => {
        this.lyricLine = " "
        this.lyricConfig.setLyric(null)
        this.lyricHelper.setLyricData(null)
        let filePath = await FileScanner.scanLyric(this.context.filesDir, this.title)
        let lrc = this.lyricParser.parse(filePath)
        Logger.d(TAG, "prepared lyricList size= " + this.lyricList.length)
        if (lrc) {
            this.lyricConfig.setLyric(lrc)
            if (lrc.lyricList.length > 0) {
                this.lyricHelper.setLyricData(lrc.lyricList)
            }
        }
    }

    aboutToAppear() {
        this.context = getContext(this)
        // this.preLyric()
        this.lyricConfig
            .setTextSize(vp2px(16))
            .setCacheSize(4)
            .setTextColor(this.theme.colorSecondary)
            .setHighlightColor(this.theme.colorPrimary)
            .setLineSpace(vp2px(14))
            .setHighlightStyle(false)
            .setEmptyHint("暂无歌词")
        this.mediaSession.onProgress(this.onProgressChanged)
        this.mediaSession.onSongChanged(this.onSongChanged)
    }

    @Styles pressedStyles() {
        .border({ radius: 200 })
        .backgroundColor(this.theme.colorAction)
    }

    @Styles normalStyles() {
        .border({ radius: 200 })
        .backgroundColor(null)
    }

    @Builder
    Title() {
        Column() {
            Text(this.title).fontSize(24).fontColor(this.theme.colorPrimary)
            Text(this.artist).fontSize(14).fontColor(this.theme.colorSecondary)
                .margin({ top: 8 })
        }
    }

    @Builder
    ProgressBar() {
        Column() {
            // slider
            Slider(
                {
                    style: SliderStyle.OutSet,
                    min: 0,
                    max: this.totalDuration,
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
                Text(timeToString(this.currentPosition)).fontSize(14).fontColor(this.theme.colorSecondary)
                Text(timeToString(this.totalDuration)).fontSize(14).fontColor(this.theme.colorSecondary)
            }.width('100%')
            .alignItems(VerticalAlign.Bottom)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 8, right: 8 })
        }.padding({ left: 16, right: 16 })
    }

    @Builder
    Cover() {
        Stack() {
            Image($r("app.media.ic_cover"))
                .objectFit(ImageFit.Cover)
                .width("100%")
                .aspectRatio(1)
                .margin(32)
        }
        .width(300)
        .aspectRatio(1)
        .border({ radius: 4 })
        .shadow({ radius: 12, color: "#ff848484" })
        .backgroundColor("#ffbce5e8")
    }

    build() {
        Stack() {
            Column() {
                // title
                this.Title()

                Stack() {
                    Column() {
                        // cover image
                        this.Cover()
                        // lyric
                        Text(this.lyricLine).fontSize(16).height(20).fontColor(this.theme.colorSecondary)
                    }
                    .width("100%")
                    .height("100%")
                    .justifyContent(FlexAlign.SpaceEvenly)
                    .opacity(this.animAlpha)
                    .animation({
                        duration: 300,
                        curve: Curve.Linear,
                        delay: 0,
                        iterations: 1, // 设置-1表示动画无限循环
                        playMode: PlayMode.Normal
                    })
                    .onClick(() => {
                        this.showLyric()
                    })

                    Column() {
                        LyricView({ lyricConfig: this.lyricConfig })
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
                        this.showLyric()
                    })
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
                    }
                })
            }
            .width('100%')
            .height('100%')
            .padding(16)
            .alignItems(HorizontalAlign.Center)
        }
        .alignContent(Alignment.TopEnd)
        .width('100%')
        .height('100%')
    }

    private async playOrPause() {
        if (this.mediaSession.isPlaying()) {
            this.mediaSession.pause()
        } else {
            this.mediaSession.start()
        }
    }

    private showLyric() {
        this.isShowLyric = !this.isShowLyric
        this.animAlpha = this.isShowLyric ? 0 : 1
    }
}