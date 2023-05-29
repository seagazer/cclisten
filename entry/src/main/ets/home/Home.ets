import { CoverView } from '../view/CoverView';
import { ActionController } from '../view/ActionController';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { LyricHelper } from '@seagazer/cclyric';
import router from '@ohos.router';
import { Logger } from '@seagazer/ccplayer/src/main/ets/player/common/Logger';
import display from '@ohos.display';
import window from '@ohos.window';

@Entry
@Component
struct Home {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    @State isPlaying: boolean = false
    @State pageScale: number = 1
    @State pageAlpha: number = 1
    @State title: string = "可能"
    @State artist: string = "程响"
    @State lyricLine: string = ""
    private lyricHelper: LyricHelper

    aboutToAppear() {
        window.getLastWindow(getContext(this), (err, win) => {
            win.setWindowLayoutFullScreen(true)
        })
        Logger.d("aaa", JSON.stringify(display.getDefaultDisplaySync()))
        router.clear()
        this.lyricHelper = new LyricHelper()
    }

    aboutToDisappear() {

    }

    @Builder
    Title() {
        Text(this.title).fontSize(56).fontColor(this.theme.colorPrimary)
        Text(this.artist).fontSize(18).fontColor(this.theme.colorPrimary)
            .margin({ top: 8 })
    }

    private playOrPause() {
        this.isPlaying = !this.isPlaying
    }

    private playNext() {
    }

    private playPre() {
    }

    build() {
        Stack() {
            Column() {
                // title
                this.Title()
                // cover image
                CoverView({ src: $r('app.media.baseline_clear_24'), isPlaying: $isPlaying })
                // single line lyric
                Text('可能南方的阳光  照着北方的风')
                    .fontSize(18)
                    .fontColor(this.theme.colorPrimary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                // slider
                Slider({
                    style: SliderStyle.InSet
                })
                    .width('100%')
                    .trackThickness(18)
                    .trackColor(this.theme.colorPrimary)
                    .selectedColor(this.theme.colorSecondary)
                // duration
                Row() {
                    Text('00:00').fontSize(24).fontColor(this.theme.colorPrimary)
                    Text('/').fontSize(18).fontColor(this.theme.colorPrimary)
                    Text('03:58').fontSize(18).fontColor(this.theme.colorPrimary).opacity(0.5)
                }.width('100%').alignItems(VerticalAlign.Bottom)

                // controller button
                ActionController({
                    isPlaying: $isPlaying,
                    actionPlayOrPause: this.playOrPause,
                    actionPlayNext: this.playNext,
                    actionPlayPre: this.playPre
                })
            }
            .width('100%')
            .height('100%')
            .padding({ left: 32, right: 32, top: 32, bottom: 32 })
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
        }
        .alignContent(Alignment.TopEnd)
        .width('100%')
        .height('100%')
        .scale({ x: this.pageScale, y: this.pageScale })
        .opacity(this.pageAlpha)
    }

    pageTransition() {
        PageTransitionEnter({ duration: 600 }).onEnter((_: RouteType, progress: number) => {
            this.pageScale = Math.min(1, progress + 0.5)
            this.pageAlpha = progress
        })
    }
}