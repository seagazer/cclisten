import { dimColor, toast } from '../extensions/Extensions';
import { Theme, THEME_COLOR } from '../theme/Theme';
import router from '@ohos.router';
import { UIConfig } from '../config/UIConfig';
import { ThemeManager } from '../theme/ThemeManager';
import { Logger } from '../extensions/Logger';

const TAG = "[PageThemeSettings]"

@Entry
@Component
export struct PageThemeSettings {
    @State selectIndex: number = 0
    private scaleSize = 1.25
    private colorPrimary: string = ""

    aboutToAppear() {
        let p = router.getParams() as Record<string, string>
        if (p) {
            this.colorPrimary = p.DATA_THEME
        }
        Logger.d(TAG, "router data = " + JSON.stringify(p))
    }

    @Styles
    normalStyles(){
        .backgroundColor(THEME_COLOR[this.selectIndex])
        .scale({ x: 1, y: 1 })
        .shadow({
            radius: UIConfig.DIMENSION_NORMAL_SHADOW,
            color: "#ccb8b8b8",
            offsetY: UIConfig.DIMENSION_OFFSET_SHADOW
        })
    }

    @Styles
    pressedStyles(){
        .backgroundColor(dimColor(THEME_COLOR[this.selectIndex]))
        .scale({ x: 0.95, y: 0.95 })
        .shadow({
            radius: UIConfig.DIMENSION_PRESS_SHADOW,
            color: "#ccb8b8b8",
            offsetY: UIConfig.DIMENSION_OFFSET_SHADOW
        })
    }

    build() {
        Column() {
            Text("请选择您喜欢的主题色")
                .fontSize(UIConfig.FONT_SUB_TITLE)
                .width("100%")
                .textAlign(TextAlign.Center)
                .padding({ top: 32 })
                .fontColor(THEME_COLOR[this.selectIndex])
                .animation({
                    duration: UIConfig.ANIM_DURATION
                })

            Scroll() {
                Row() {
                    ForEach(THEME_COLOR, (color: string, index) => {
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
                                duration: UIConfig.ANIM_DURATION
                            })
                            .onClick(() => {
                                this.selectIndex = index
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

            Text("确定")
                .fontSize(UIConfig.FONT_BUTTON)
                .fontColor("#ffffff")
                .textAlign(TextAlign.Center)
                .width(150)
                .height(50)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin(48)
                .border({ radius: 50 })
                .stateStyles({
                    normal: this.normalStyles,
                    pressed: this.pressedStyles
                })
                .onClick(() => {
                    this.setTheme()
                })
                .animation({
                    duration: UIConfig.ANIM_DURATION
                })
        }
        .width("100%")
        .height("100%")
        .padding(32)
        .justifyContent(FlexAlign.Center)
        .onAppear(() => {
            Logger.d(TAG, "current colorPrimary = " + this.colorPrimary)
            for (let i = 0; i < THEME_COLOR.length; i++) {
                if (this.colorPrimary == THEME_COLOR[i]) {
                    this.selectIndex = i
                }
            }
        })
    }

    private async setTheme() {
        let theme = new Theme(THEME_COLOR[this.selectIndex])
        ThemeManager.get().updateTheme(theme)
        await ThemeManager.get().saveTheme(theme)
        router.back()
    }
}