import { CoverView } from '../view/CoverView';
import { ActionController } from '../view/ActionController';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { LyricHelper } from '@seagazer/cclyric';
import { toast } from '../extensions/Extensions';

@Entry
@Component
struct Index {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    @State isPlaying: boolean = false
    @State pageScale: number = 0
    @State pageAlpha: number = 0
    @State title: string = "可能"
    @State artist: string = "程响"
    @State lyricLine: string = ""
    private lyricHelper: LyricHelper

    aboutToAppear() {
        this.lyricHelper = new LyricHelper()
    }

    aboutToDisappear() {

    }

    @Builder
    Title() {
        Text(this.title).fontSize(56).fontColor(this.theme.colorPrimary)
        Text(this.artist).fontSize(18).fontColor(this.theme.colorPrimary)
            .opacity(0.5)
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
                CoverView({ src: $r('app.media.cover'), isPlaying: $isPlaying })
                // single line lyric
                Text('可能南方的阳光  照着北方的风')
                    .fontSize(18)
                    .fontColor(this.theme.colorPrimary)
                    .opacity(0.5)
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
            .padding({ left: 16, right: 16, top: 32, bottom: 32 })
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)

            // share link
            Image($r('app.media.ic_link'))
                .width(48)
                .aspectRatio(1)
                .margin(16)
                .padding(4)
                .colorBlend(this.theme.colorPrimary)
                .border({
                    radius: 48,
                })
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    toast("todo", 1500)
                })
        }
        .alignContent(Alignment.TopEnd)
        .width('100%')
        .height('100%')
        .scale({ x: this.pageScale, y: this.pageScale })
        .opacity(this.pageAlpha)
    }

    pageTransition() {
        PageTransitionEnter({ duration: 600 }).onEnter((type: RouteType, progress: number) => {
            this.pageScale = Math.min(1, progress + 0.5)
            this.pageAlpha = progress
        })
    }

    @Styles pressedStyles() {
        .backgroundColor(this.theme.colorAction)
    }

    @Styles normalStyles() {
        .backgroundColor(null)
    }
}