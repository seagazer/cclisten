import { PlayButton } from "../widget/PlayButton"

@Entry
@Component
struct Index {
    private ctx = new CanvasRenderingContext2D()
    private w = 0
    private h = 0
    @State alpha: number = 0.6
    private themeColor = "#000000"

    build() {
        Column() {
            // title
            Text("可能").fontSize(56).fontColor(this.themeColor)
            Text("程响").fontSize(18).fontColor(this.themeColor).margin({ top: 8 })
            // cover image
            Image($r("app.media.cover"))
                .width("75%")
                .aspectRatio(1)
                .border({
                    radius: "200",
                    color: this.themeColor,
                    width: 8
                })
                .margin({ top: 64, bottom: 64 })
                .opacity(this.alpha)
                .animation({
                    duration: 4000,
                    playMode: PlayMode.Alternate,
                    iterations: -1
                })
                .onClick(() => {
                    this.alpha = 1
                })
            // lyric
            Text("可能南方的阳光  照着北方的风").fontSize(18)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

            Blank()
            // slider
            Slider({
                style: SliderStyle.InSet
            })
                .width("100%")
                .trackThickness(18)
                .trackColor(this.themeColor)
            // duration
            Row() {
                Text("00:58").fontSize(18)
                Text("/").fontSize(18)
                Text("03:58").fontSize(18).opacity(0.5)
            }.width("100%")

            // controller button
            Row() {
                Image($r("app.media.play_96px")).width(72).aspectRatio(1).padding(4)
                    .border({
                        radius: 72,
                        color: this.themeColor,
                        width: 2
                    })
                Image($r("app.media.rewind_96px"))
                    .width(48)
                    .aspectRatio(1)
                    .margin({ left: 16, right: 16 })
                    .padding(4)
                    .border({
                        radius: 48,
                        color: this.themeColor,
                        width: 2
                    })
                Image($r("app.media.fast_forward_96px"))
                    .width(48)
                    .aspectRatio(1)
                    .padding(4)
                    .border({
                        radius: 48,
                        color: this.themeColor,
                        width: 2
                    })
            }
            .width("100%")
            .margin({ top: 48 })
        }
        .width('100%')
        .height('100%')
        .padding({ left: 16, right: 16, top: 48, bottom: 48 })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
    }
}