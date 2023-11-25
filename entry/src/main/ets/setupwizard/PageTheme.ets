import { navigationTo } from '../extensions/Extensions';
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
export struct PageTheme {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    private colorPrimaryList = ["#FF405C", "#007DFF", "#47CC47", "#FF7500",
        "#E40078", "#00AAEE"]
    @State selectIndex: number = 0
    private scaleSize = 1.25

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
                }
            }
            .height(64)
            .width("100%")
            .margin({ top: 48 })

            Fab({
                text: "下一步",
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
    }

    private async setTheme() {
        let theme = new Theme(this.colorPrimaryList[this.selectIndex])
        ThemeManager.get().updateTheme(theme)
        await ThemeManager.get().saveTheme(theme)
        await UserConfigHelper.get(getContext(this)).write(UserConfigHelper.CONFIG_INIT_STEP, 1)
        navigationTo(PageRouter.PAGE_SETUPWIZARD_MEDIA_LIBRARY)
    }
}