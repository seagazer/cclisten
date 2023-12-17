import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { Song } from '../bean/Song'
import { APP_THEME } from '../extensions/LiveData'
import { UIConfig } from '../config/UIConfig'

@Component
export struct PlaylistItemView {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    data?: Song = undefined
    isHighLight: boolean = false
    onAction = (song: Song) => {
    }
    onDelete = (song: Song) => {
    }

    @Styles
    pressedStyles() {
        .border({ radius: UIConfig.DIMENSION_CORNER })
        .backgroundColor(DEFAULT_THEME.colorAction)
    }

    @Styles
    normalStyles() {
        .backgroundColor(null)
    }

    build() {
        Row() {
            Row() {
                Text(this.data!.title + " - ")
                    .fontSize(18)
                    .fontColor(this.isHighLight ? this.theme.colorPrimary : "#000000")
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(this.data!.artist ? this.data!.artist : "未知")
                    .fontColor(this.isHighLight ? this.theme.colorPrimary : "#ffa4a4a4")
                    .fontSize(16)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .height("100%")
            .layoutWeight(1)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
                this.onAction(this.data)
            })

            Image($r("app.media.ic_public_cancel"))
                .width(36)
                .height(36)
                .padding(6)
                .fillColor("#ffa4a4a4")
                .onClick(() => {
                    this.onDelete(this.data)
                })
        }
        .width("100%")
        .height(56)
        .padding({ left: 16, right: 16 })
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
    }
}