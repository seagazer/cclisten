import { navigationTo, toast } from '../extensions/Extensions';
import { PageRouter } from '../extensions/PageRouter';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { Fab } from '../view/Fab';
import router from '@ohos.router';
import { APP_THEME } from '../extensions/LiveData';
import { UIConfig } from '../config/UIConfig';
import { ThemeManager } from '../theme/ThemeManager';
import { UserConfigHelper } from '../base/UserConfigHelper';

@Entry
@Component
export struct PageThemeSettings {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    private colorPrimaryList = ["#FF405C", "#007DFF", "#47CC47", "#FF7500",
        "#E40078", "#00AAEE"]
    @State selectIndex: number = 0
    private scaleSize = 1.25

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

            Scroll() {
                Row() {
                    ForEach(this.colorPrimaryList, (color: string, index) => {
                        Stack()
                            .width(40)
                            .height(40)
                            .margin({ left: 20 })
                            .backgroundColor(color)
                            .border({ radius: 100, color: Color.Black, width: this.selectIndex == index ? 1 : 0 })
                            .scale({
                                x: this.selectIndex == index ? this.scaleSize : 1,
                                y: this.selectIndex == index ? this.scaleSize : 1
                            })
                            .animation({
                                duration: 300
                            })
                            .onClick(() => {
                                this.selectIndex = index
                                let theme = new Theme(this.colorPrimaryList[this.selectIndex])
                                ThemeManager.get().updateTheme(theme)
                            })
                    })
                    Stack()
                        .width(40)
                        .height(40)
                        .margin({ left: 20 })
                        .backgroundColor("#ffffff")
                        .border({ radius: 100, color: Color.Grey, width: 1 })
                        .onClick(() => {
                            // todo
                            toast("ColorWheel")
                        })
                }.justifyContent(FlexAlign.SpaceEvenly)
            }
            .scrollBar(BarState.Off)
            .scrollable(ScrollDirection.Horizontal)
            .height(64)
            .width("100%")
            .margin({ top: 48 })

            Fab({
                text: "确定",
                textSize: UIConfig.FONT_BUTTON,
                marginSize: { top: 48 },
                onAction: () => {
                    this.setTheme()
                }
            })
        }
        .width("100%")
        .height("100%")
        .padding(32)
        .justifyContent(FlexAlign.Center)
        .onAppear(() => {
            for (let i = 0; i < this.colorPrimaryList.length; i++) {
                if (this.theme.colorPrimary == this.colorPrimaryList[i]) {
                    this.selectIndex = i
                }
            }
        })
    }

    private async setTheme() {
        let theme = new Theme(this.colorPrimaryList[this.selectIndex])
        ThemeManager.get().updateTheme(theme)
        await ThemeManager.get().saveTheme(theme)
        router.back()
    }
}