import { DEFAULT_THEME, Theme } from '../theme/Theme'

@Entry
@Component
export struct PageSetup {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME

    build() {
        Column() {
            Text("欢迎")
                .fontSize(48)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.theme.colorPrimary)

            Button("下一步")
                .fontSize(16)
                .margin({ top: 32 })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
    }
}