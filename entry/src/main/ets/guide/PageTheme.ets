import { navigationTo } from '../extensions/Extensions';
import { PageRouter } from '../extensions/PageRouter';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { Fab } from '../view/Fab';
import router from '@ohos.router';
import { APP_THEME } from '../extensions/LiveData';
import { UIConfig } from '../config/UIConfig';
import { ThemeManager } from '../theme/ThemeManager';

@Entry
@Component
export struct PageTheme {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    private colorPrimaryList = ["#ffFF405C", "#ff9456ff", "#ffd7c12d", "#ff22c25a",
        "#ffff8244", "#ff2a82df"]
    private colorSecondaryList = ["#cccb2039", "#cc5c26ba", "#cc988613", "#cc0c8f3a",
        "#ccae4e1d", "#cc1258a3"]
    @State selectIndex: number = 0
    private scaleSize = 1.2

    aboutToAppear() {
        router.clear()
    }

    build() {
        Column() {
            Text("请选择您喜欢的主题色")
                .fontSize(UIConfig.FONT_SUB_TITLE)
                .width("100%")
                .textAlign(TextAlign.Center)
                .padding({ top: 32 })
                .fontColor(this.colorPrimaryList[this.selectIndex])
                .animation({
                    duration: 300
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
                    AppStorage.set<string>("isAppInit", "1")
                    navigationTo(PageRouter.PAGE_GUIDE_FILE_LIST)
                }
            })
        }
        .width("100%")
        .height("100%")
        .padding(32)
        .justifyContent(FlexAlign.Center)
    }
}