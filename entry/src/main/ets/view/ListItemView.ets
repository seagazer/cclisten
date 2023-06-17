import { DEFAULT_THEME } from '../theme/Theme'
import { Song } from '../bean/Song'

@Component
export struct ListItemView {
    index: number
    data: Song
    onItemClick: (song: Song) => void

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
        }
        .width("100%")
        .height(56)
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
    }
}