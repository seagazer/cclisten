import { navigationTo } from '../extensions/Extensions';
import { PageRouter } from '../extensions/PageRouter';
import { APP_THEME, DEFAULT_THEME, Theme } from '../theme/Theme'
import { ThemeManager } from '../theme/ThemeManager';
import { Fab } from '../view/Fab';
import router from '@ohos.router';

@Entry
@Component
export struct PageSetup {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    private colorPrimaryList = ["#ff7D56C0", "#ffbba41e", "#ff29b523",
        "#ffba5d30", "#ffFF405C", "#ff007DFE"]
    private colorSecondaryList = ["#ff96aef8", "#ffeed964", "#ff4ede47",
        "#ffe38151", "#ffec3cc9", "#ff5aa9fb"]
    @State selectIndex: number = 0
    private themeColor: string

    aboutToAppear() {
        this.themeColor = this.theme.colorPrimary
        router.clear()
    }

    @Builder
    ThemeItem(color1, color2) {
        Row() {
            Stack().height("100%").layoutWeight(1).backgroundColor(color1)
            Stack()
                .height("100%")
                .layoutWeight(1)
                .backgroundColor(color2)
        }.width("100%").height("100%")
    }

    build() {
        Column() {
            Row() {
                Image($r("app.media.ic_theme")).width(56).height(56)
                Text("请选择您喜欢的主题色")
                    .fontSize(16)
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
                        .border({ radius: 8, color: "#ffd6386f", width: 2 })
                        .onClick(() => {
                            this.selectIndex = index
                        })
                    } else {
                        GridItem() {
                            this.ThemeItem(color, this.colorSecondaryList[index])
                        }
                        .width(100)
                        .height(50)
                        .border({ radius: 8, color: "#ffffff", width: 2 })
                        .onClick(() => {
                            this.selectIndex = index
                        })
                    }
                })
            }
            .columnsTemplate("1fr 1fr 1fr")
            .rowsGap(16)
            .columnsGap(16)
            .margin({ top: 48 })
            .height(116)

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