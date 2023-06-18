import { navigationTo } from '../extensions/Extensions';
import { PageRouter } from '../extensions/PageRouter';
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { ThemeManager } from '../theme/ThemeManager';
import { Fab } from '../view/Fab';
import router from '@ohos.router';
import { APP_THEME } from '../extensions/LiveData';

@Entry
@Component
export struct PageSetup {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    private colorPrimaryList = ["#ffFF405C", "#ff9456ff", "#ffd7c12d", "#ff22c25a",
        "#ffff8244", "#ff2a82df"]
    private colorSecondaryList = ["#cccb2039", "#cc5c26ba", "#cc988613", "#cc0c8f3a",
        "#ccae4e1d", "#cc1258a3"]
    @State selectIndex: number = 0
    private themeColor: string

    aboutToAppear() {
        router.clear()
        this.themeColor = this.theme.colorPrimary
    }

    @Builder
    ThemeItem(color1, color2) {
        Row() {
            Stack().height("100%").layoutWeight(1).backgroundColor(color1)
            Stack()
                .height("100%")
                .layoutWeight(1)
                .backgroundColor(color2)
        }
        .width("100%").height("100%")
    }

    build() {
        Column() {
            Row() {
                Image($r("app.media.ic_theme")).width(56).height(56)
                Text("请选择您喜欢的主题色")
                    .fontSize(18)
                    .width("100%")
                    .textAlign(TextAlign.Start)
                    .padding({ left: 16 })
                    .fontColor(this.theme.colorPrimary)
            }

            Grid() {
                ForEach(this.colorPrimaryList, (color: string, index) => {
                    if (this.selectIndex == index) {
                        GridItem() {
                            this.ThemeItem(color, this.colorSecondaryList[index])
                        }
                        .width(100)
                        .height(50)
                        .border({ color: this.theme.colorPrimary, width: 2 })
                        .onClick(() => {
                            this.selectIndex = index
                        })
                    } else {
                        GridItem() {
                            this.ThemeItem(color, this.colorSecondaryList[index])
                        }
                        .width(100)
                        .height(50)
                        .onClick(() => {
                            this.selectIndex = index
                        })
                    }
                })
            }
            .align(Alignment.Center)
            .columnsTemplate("1fr 1fr 1fr")
            .rowsGap(16)
            .columnsGap(16)
            .margin({ top: 48 })
            .height(126)

            Fab({
                text: "确定",
                textSize: 18,
                color: this.themeColor,
                marginSize: { top: 56 },
                onAction: () => {
                    ThemeManager.updateTheme(new Theme(this.colorPrimaryList[this.selectIndex],
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