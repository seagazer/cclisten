import { ActionController } from '../view/ActionController';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { LyricHelper, LyricParser } from '@seagazer/cclyric';
import router from '@ohos.router';
import display from '@ohos.display';
import window from '@ohos.window';
import { MockData } from './MockData';
import { duration2time as timeToString } from '../extensions/Extensions';
import { CcPlayer, MediaSourceFactory, Logger, PlayerType } from '@seagazer/CcPlayer';

const TAG = "Home"

@Entry
@Component
struct Home {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    @State isPlaying: boolean = false
    @State pageScale: number = 1
    @State pageAlpha: number = 1
    @State title: string = "可能"
    @State artist: string = "程响"
    @State lyricLine: string = "暂无歌词"
    private lyricHelper: LyricHelper
    private player: CcPlayer = null
    @State currentPosition: number = 0
    @State totalDuration: number = 0
    private progressChangedListener = (duration: number) => {
        this.currentPosition = duration
        this.lyricLine = this.lyricHelper.getLyric(duration)
    }
    private prepareListener = () => {
        this.totalDuration = this.player.getDuration()
    }

    aboutToAppear() {
        router.clear()
        this.player = CcPlayer.create(PlayerType.AUDIO)
        Logger.w(TAG, "media player = " + this.player)
        MediaSourceFactory.createAssets(getContext(this), "../../resources/rawfile/可能.mp3", "可能")
            .then((source) => {
                this.player.setMediaSource(source)
            })
        this.player
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnPreparedListener(this.prepareListener)

        this.lyricHelper = new LyricHelper()
        let lyricParser = new LyricParser()
        this.lyricHelper.setLyricData(lyricParser.parse(MockData.src1))
    }

    aboutToDisappear() {
        this.player
            .removeOnPreparedListener(this.prepareListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
    }

    @Builder
    Title() {
        Text(this.title).fontSize(24).fontColor(this.theme.colorPrimary)
        Text(this.artist).fontSize(16).fontColor(this.theme.colorPrimary)
            .margin({ top: 8 })
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
                .selectedColor(this.theme.colorSecondary)
                .blockColor(this.theme.colorSecondary)
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                        this.player.seekTo(value)
                    }
                })
            // duration
            Row() {
                Text(timeToString(this.currentPosition)).fontSize(16).fontColor(this.theme.colorPrimary)
                Text(timeToString(this.totalDuration)).fontSize(16).fontColor(this.theme.colorPrimary)
            }.width('100%')
            .alignItems(VerticalAlign.Bottom)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 8, right: 8 })
        }.padding({ left: 16, right: 16 })
    }

    @Builder
    Cover() {
        Image($r("app.media.cover"))
            .width(240)
            .height(240)
            .objectFit(ImageFit.Cover)
            .border({ radius: 16 })
    }

    build() {
        Stack() {
            Column() {
                // title
                this.Title()
                Column() {
                    // cover image
                    this.Cover()
                    // lyric
                    Text(this.lyricLine).fontSize(16).height(20)
                }
                .width("100%")
                .layoutWeight(1)
                .justifyContent(FlexAlign.SpaceEvenly)

                // progress
                this.ProgressBar()
                // controller button
                ActionController({
                    isPlaying: $isPlaying,
                    actionPlayOrPause: this.playOrPause.bind(this),
                    actionPlayNext: this.playNext.bind(this),
                    actionPlayPre: this.playPre.bind(this)
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
        .scale({ x: this.pageScale, y: this.pageScale })
        .opacity(this.pageAlpha)
    }

    private playOrPause() {
        Logger.d(TAG, "media player = " + this.player)
        if (this.player.isPlaying()) {
            this.player.pause()
            this.isPlaying = false
        } else {
            this.player.start()
            this.isPlaying = true
        }
    }

    private playNext() {
    }

    private playPre() {
    }

    pageTransition() {
        PageTransitionEnter({ duration: 600 }).onEnter((_: RouteType, progress: number) => {
            this.pageScale = Math.min(1, progress + 0.5)
            this.pageAlpha = progress
        })
    }
}