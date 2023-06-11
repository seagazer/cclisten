import { Song } from '../bean/Song'
import { DEFAULT_THEME } from '../theme/Theme'
import { ExtImage } from '../view/ExtImage'
import mediaLibrary from '@ohos.multimedia.mediaLibrary'

@Component
export struct ListItemView {
    index: number
    data: mediaLibrary.FileAsset
    onItemClick: (song: mediaLibrary.FileAsset) => void

    @Styles pressedStyles() {
        .backgroundColor(DEFAULT_THEME.colorAction)
    }

    @Styles normalStyles() {
        .backgroundColor(null)
    }

    build() {
        Row() {
            Text(this.index > 0 ? String(this.index) : "-")
                .fontSize(16)
                .width(40)
                .textAlign(TextAlign.Center)

            Column() {
                Text(this.data.title).fontSize(18)
                Text(this.data.artist ? this.data.artist : "未知")
                    .fontSize(12)
                    .fontColor("#cccccc")
                    .margin({ top: 2 })
            }
            .padding({ left: 16 })
            .layoutWeight(1)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(HorizontalAlign.Start)

            // Stack() {
            //     ExtImage({
            //         src: $r("app.media.baseline_skip_previous_24"),
            //         widthSize: "100%",
            //         heightSize: "100%",
            //         paddingSize: 8,
            //         borderOp: { radius: 40 }
            //     })
            // }
            // .height("100%")
            // .aspectRatio(1)
        }
        .width("100%")
        .height(56)
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
        // .onClick(() => {
        //     this.onItemClick?.(this.data)
        // })
    }
}