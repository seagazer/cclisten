import { CoverView } from '../view/CoverView';
import { ActionController } from '../view/ActionController';

@Extend(Image) function playBtnStyle(size: Length, padding: Length, margin: Length, color: ResourceColor) {
    .width(size)
    .aspectRatio(1)
    .padding(padding)
    .margin({ left: margin, right: margin })
    .border({
        radius: size,
        color: color,
        width: 2
    })
}

@Entry
@Component
struct Index {
    private ctx = new CanvasRenderingContext2D()
    private w = 0
    private h = 0
    private themeColor = '#ff000000'
    @State isPlaying: boolean = false

    @Styles pressedStyles() {
        .backgroundColor("#cce2e2e2")
    }

    @Builder
    Title() {
        Text('可能').fontSize(56).fontColor(this.themeColor)
        Text('程响').fontSize(18).fontColor(this.themeColor)
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

    aboutToAppear() {
    }

    build() {
        Stack() {
            Column() {
                // title
                this.Title()
                // cover image
                CoverView({ src: $r('app.media.cover'), isPlaying: $isPlaying, themeColor: this.themeColor })
                // lyric
                Text('可能南方的阳光  照着北方的风')
                    .fontSize(18)
                    .fontColor(this.themeColor)
                    .opacity(0.5)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                // slider
                Slider({
                    style: SliderStyle.InSet
                })
                    .width('100%')
                    .trackThickness(18)
                    .trackColor(this.themeColor)
                    .selectedColor("#cce2e2e2")
                // duration
                Row() {
                    Text('00:58').fontSize(24).fontColor(this.themeColor)
                    Text('/').fontSize(18).fontColor(this.themeColor)
                    Text('03:58').fontSize(18).fontColor(this.themeColor).opacity(0.5)
                }.width('100%').alignItems(VerticalAlign.Bottom)

                // controller button
                ActionController({
                    isPlaying: $isPlaying,
                    themeColor: this.themeColor,
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
                .colorBlend(this.themeColor)
                .border({
                    radius: 48,
                })
                .stateStyles({
                    pressed: this.pressedStyles
                })
        }
        .alignContent(Alignment.TopEnd)
        .width('100%')
        .height('100%')
    }
}