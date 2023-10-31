import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { Song } from '../bean/Song'
import { APP_THEME } from '../extensions/LiveData'
import { UIConfig } from '../config/UIConfig'

@Component
export struct SelectItemView {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @ObjectLink song: Song
    onItemSelectChanged: () => void = () => {
    }

    build() {
        Row() {
            Checkbox()
                .width(24)
                .height(24)
                .selectedColor(this.theme.colorPrimary)
                .select(this.song.isAdd == 1)
                .onChange((isChecked) => {
                    this.song.isAdd = isChecked ? 1 : 0
                    this.onItemSelectChanged?.()
                })

            Column() {
                Text(this.song.title)
                    .fontSize(UIConfig.FONT_CONTENT)
                    .fontColor("#000000")
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(this.song.artist ? this.song.artist : "未知")
                    .fontColor("#ffa4a4a4")
                    .fontSize(UIConfig.FONT_SUB_CONTENT)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 2 })
            }
            .padding({ left: 16, right: 16 })
            .layoutWeight(1)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(HorizontalAlign.Start)

        }
        .width("100%")
        .height(56)
        .alignItems(VerticalAlign.Center)
    }
}