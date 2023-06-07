import { navigationTo } from '../extensions/Extensions';
import { PageRouter } from '../extensions/PageRouter';
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { ThemeManager } from '../theme/ThemeManager';

@Entry
@Component
export struct PageSetup {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    @State step: number = 1
    private colorPrimaryList = ["#ff7D56C0", "#ffbba41e", "#ff29b523",
        "#ffba5d30", "#ffc83c72", "#ff007DFE"]
    private colorSecondaryList = ["#ff96aef8", "#ffeed964", "#ff4ede47",
        "#ffe38151", "#fff06198", "#ff5aa9fb"]
    @State selectIndex: number = 0

    build() {
        Column() {
            if (this.step == 0) {
                Column() {
                    Text("请选择主题色")
                        .fontSize(48)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.theme.colorPrimary)

                    Button("下一步")
                        .width(100)
                        .height(50)
                        .type(ButtonType.Normal)
                        .shadow({ radius: 16, color: "#999c9c9c" })
                        .fontSize(16)
                        .margin({ top: 48 })
                        .onClick(() => {
                            this.step++
                        })
                }
                .width("100%")
                .height("100%")
                .justifyContent(FlexAlign.Center)
            } else if (this.step == 1) {
                Column() {
                    Text("主题色").fontSize(24).width("100%")
                    Grid() {
                        ForEach(this.colorPrimaryList, (color: string, index) => {
                            if (this.selectIndex == index) {
                                GridItem() {
                                    Row() {
                                        Stack().height("100%").layoutWeight(1).backgroundColor(color)
                                        Stack()
                                            .height("100%")
                                            .layoutWeight(1)
                                            .backgroundColor(this.colorSecondaryList[index])
                                    }.width("100%").height("100%")
                                }
                                .width(100)
                                .height(50)
                                .border({ radius: 4, color: "#ffffdd30", width: 2 })
                                .onClick(() => {
                                    this.selectIndex = index
                                })
                            } else {
                                GridItem() {
                                    Row() {
                                        Stack().height("100%").layoutWeight(1).backgroundColor(color)
                                        Stack()
                                            .height("100%")
                                            .layoutWeight(1)
                                            .backgroundColor(this.colorSecondaryList[index])
                                    }.width("100%").height("100%")
                                }
                                .width(100)
                                .height(50)
                                .border({ radius: 4 })
                                .onClick(() => {
                                    this.selectIndex = index
                                })
                            }
                        })
                    }
                    .columnsTemplate("1fr 1fr 1fr")
                    .rowsGap(16)
                    .columnsGap(16)
                    .margin({ top: 16 })
                    .height(160)

                    Button("确定")
                        .width(100)
                        .height(50)
                        .type(ButtonType.Normal)
                        .shadow({ radius: 16, color: "#999c9c9c" })
                        .fontSize(16)
                        .margin({ top: 36 })
                        .onClick(() => {
                            ThemeManager.setTheme(new Theme(this.colorPrimaryList[this.selectIndex],
                                this.colorSecondaryList[this.selectIndex]))
                            navigationTo(PageRouter.PAGE_HOME)
                        })
                }
                .width("100%")
                .height("100%")
                .padding(32)
                .justifyContent(FlexAlign.Center)
            }
        }
        .width("100%")
        .height("100%")
    }
}