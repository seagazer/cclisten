import { navigationTo } from '../extensions/Extensions';
import { PageRouter } from '../extensions/PageRouter';
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { ThemeManager } from '../theme/ThemeManager';
import router from '@ohos.router';
import { Fab } from '../view/Fab';

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
    private themeColor: string

    aboutToAppear() {
        this.themeColor = this.theme.colorPrimary
        router.clear()
    }

    build() {
        Column() {
            if (this.step == 0) {
                Column() {
                    Text("请选择主题色")
                        .fontSize(48)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.theme.colorPrimary)

                    Fab({
                        text: "下一步",
                        textSize: 18,
                        color: this.themeColor,
                        marginSize: { top: 32 },
                        onAction: () => {
                            this.step++
                        }
                    })
                }
                .width("100%")
                .height("100%")
                .justifyContent(FlexAlign.Center)
            } else if (this.step == 1) {
                Column() {
                    Text("请选择主题色").fontSize(24).width("100%")
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

                    Fab({
                        text: "确定",
                        textSize: 18,
                        color: this.themeColor,
                        marginSize: { top: 32 },
                        onAction: () => {
                            ThemeManager.setTheme(new Theme(this.colorPrimaryList[this.selectIndex],
                                this.colorSecondaryList[this.selectIndex]))
                            navigationTo(PageRouter.PAGE_HOME)
                        }
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