import { UIConfig } from '../config/UIConfig'
import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { ThemeManager } from '../theme/ThemeManager'
import { ColorWheelView } from '../view/ColorWheelView'
import { Fab } from '../view/Fab'

@Entry
@Component
struct PageThemeSettings {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    private colorPrimaryList = ["#ffFF405C", "#ff9456ff", "#ffd7c12d", "#ff22c25a",
        "#ffff8244", "#ff2a82df"]
    private colorSecondaryList = ["#cccb2039", "#cc5c26ba", "#cc988613", "#cc0c8f3a",
        "#ccae4e1d", "#cc1258a3"]
    @State selectIndex: number = 0
    private scaleSize = 1.2

    build() {
        Column() {
            ColorWheelView({
                radius: 300,
                onColorSelected: (color) => {
                    
                }
            })

            Grid() {
                ForEach(this.colorPrimaryList, (color: string, index) => {
                    GridItem() {
                        Stack()
                            .width(40)
                            .height(40)
                            .border({ radius: 64, color: Color.Black, width: this.selectIndex == index ? 2 : 0 })
                            .backgroundColor(color)
                            .scale({
                                x: this.selectIndex == index ? this.scaleSize : 1,
                                y: this.selectIndex == index ? this.scaleSize : 1
                            })
                            .animation({
                                duration: 300
                            })
                            .onClick(() => {
                                this.selectIndex = index
                                let theme = new Theme(this.colorPrimaryList[this.selectIndex], this.colorSecondaryList[this.selectIndex])
                                ThemeManager.get().updateTheme(theme)
                            })
                    }
                })
            }
            .columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr")
            .height(80)
            .rowsGap(16)
            .columnsGap(16)
            .margin({ top: 48 })
            .padding(16)

            Fab({
                text: "下一步",
                textSize: UIConfig.FONT_BUTTON,
                marginSize: { top: 56 },
                onAction: () => {
                    let theme = new Theme(this.colorPrimaryList[this.selectIndex], this.colorSecondaryList[this.selectIndex])
                    ThemeManager.get().updateTheme(theme)
                    ThemeManager.get().saveTheme(theme)
                }
            })
        }
        .width("100%")
        .height("100%")
        .padding(32)
        .justifyContent(FlexAlign.Center)
    }
}