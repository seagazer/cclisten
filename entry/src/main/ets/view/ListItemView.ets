import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { Song } from '../bean/Song'
import { APP_THEME } from '../extensions/LiveData'

@Component
export struct ListItemView {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    index: number
    data: Song
    onItemClick: (song: Song) => void
    isHighLight: boolean = false

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
                .fontColor(this.isHighLight ? this.theme.colorPrimary : "#000000")
                .textAlign(TextAlign.Center)

            Column() {
                Text(this.data.title)
                    .fontSize(18)
                    .fontColor(this.isHighLight ? this.theme.colorPrimary : "#000000")
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(this.data.artist ? this.data.artist : "未知")
                    .fontColor(this.isHighLight ? this.theme.colorSecondary : "#ffa4a4a4")
                    .fontSize(12)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 2 })
            }
            .padding({ left: 16 })
            .layoutWeight(1)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(HorizontalAlign.Start)

            if (this.isHighLight) {
                Image($r("app.media.ic_equalizer"))
                    .width(56)
                    .height(56)
                    .padding(16)
            }
        }
        .width("100%")
        .height(56)
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
    }
}