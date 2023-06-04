import { MediaControlBar } from '../view/MediaControlBar';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { LyricConfig, LyricHelper, LyricParser, LyricView } from '@seagazer/cclyric';
import router from '@ohos.router';
import { MockData } from './MockData';
import { duration2text as timeToString, toast } from '../extensions/Extensions';
import { CcPlayer, MediaSourceFactory, PlayerType } from '@seagazer/ccplayer';
import { PlayerMode } from '../mode/PlayerMode';
import { Logger } from '../extensions/Logger';

const TAG = "Home"

@Extend(Image) function btnStyle() {
    .width(48)
    .height(48)
    .padding(12)
}


@Entry
@Component
struct Home {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    @State isPlaying: boolean = false
    @State pageScale: number = 1
    @State pageAlpha: number = 1
    @State title: string = "可能"
    @State artist: string = "程响"
    @State lyricLine: string = " "
    @State isShowLyric: boolean = false
    private lyricConfig: LyricConfig = new LyricConfig()
    private lyricHelper: LyricHelper
    private player: CcPlayer = null
    @State currentPosition: number = 0
    @State totalDuration: number = 0
    private progressChangedListener = (duration: number) => {
        this.currentPosition = duration
        this.lyricConfig.updatePosition(duration)
        this.lyricLine = this.lyricHelper.getLyric(duration)
    }
    private prepareListener = () => {
        this.totalDuration = this.player.getDuration()
    }
    private completedListener = () => {
        this.currentPosition = this.player.getCurrentPosition()
        this.isPlaying = this.player.isPlaying()
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
            .addOnCompletionListener(this.completedListener)

        this.lyricHelper = new LyricHelper()
        let lyricParser = new LyricParser()
        let lyricData = lyricParser.parse(MockData.src1)
        this.lyricHelper.setLyricData(lyricData.lyricList)

        this.lyricConfig
            .setTextSize(24)
            .setCacheSize(4)
            .setTextColor(this.theme.colorSecondary)
            .setHighlightColor(this.theme.colorPrimary)
            .setLineSpace(24)
            .setHighlightStyle(false)
            .setEmptyHint("暂无歌词")
        this.lyricConfig.setLyric(lyricData)
    }

    aboutToDisappear() {
        this.player
            .removeOnPreparedListener(this.prepareListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnCompletionListener(this.completedListener)
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
        Row() {
            Image($r("app.media.baseline_arrow_back_ios_24")).btnStyle().stateStyles({
                pressed: this.pressedStyles,
                normal: this.normalStyles
            }).onClick(() => {
                router.back()
            })
            Column() {
                Text(this.title).fontSize(24).fontColor(this.theme.colorPrimary)
                Text(this.artist).fontSize(16).fontColor(this.theme.colorPrimary)
                    .margin({ top: 8 })
            }

            Image($r("app.media.baseline_more_vert_24")).btnStyle().stateStyles({
                pressed: this.pressedStyles,
                normal: this.normalStyles
            }).onClick(() => {
                toast("TODO")
            })
        }.width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
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

    @State alpha: number = 1

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
                        Text(this.lyricLine).fontSize(16).height(20)
                    }
                    .width("100%")
                    .height("100%")
                    .justifyContent(FlexAlign.SpaceEvenly)
                    .opacity(this.alpha)
                    .animation({
                        duration: 300,
                        curve: Curve.Linear,
                        delay: 0,
                        iterations: 1, // 设置-1表示动画无限循环
                        playMode: PlayMode.Normal
                    })

                    Column() {
                        LyricView({ lyricConfig: this.lyricConfig })
                            .width("100%")
                            .height("100%")
                    }
                    .width("100%")
                    .height("100%")
                    .padding(32)
                    .opacity(1 - this.alpha)
                    .animation({
                        duration: 300,
                        curve: Curve.Linear,
                        delay: 0,
                        iterations: 1, // 设置-1表示动画无限循环
                        playMode: PlayMode.Normal
                    })
                }
                .width("100%")
                .layoutWeight(1)

                // progress
                this.ProgressBar()
                // controller button
                MediaControlBar({
                    isPlaying: $isPlaying,
                    actionPlayOrPause: this.playOrPause.bind(this),
                    actionPlayNext: this.playNext.bind(this),
                    actionPlayPre: this.playPre.bind(this),
                    actionLyric: this.showLyric.bind(this),
                    onModeChanged: this.onModeChanged.bind(this)
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

    private showLyric() {
        this.isShowLyric = !this.isShowLyric
        this.alpha = this.isShowLyric ? 0 : 1
    }

    private onModeChanged(mode: PlayerMode) {
        Logger.d(TAG, "-----" + mode)
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