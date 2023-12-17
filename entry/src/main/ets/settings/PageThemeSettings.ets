import { dimColor, toast } from '../extensions/Extensions';
import { Theme, THEME_COLOR } from '../theme/Theme';
import router from '@ohos.router';
import { UIConfig } from '../config/UIConfig';
import { ThemeManager } from '../theme/ThemeManager';
import { Logger } from '../extensions/Logger';
import { CustomThemeDialog } from '../view/CustomThemeDialog';

const TAG = "[PageThemeSettings]"

@Entry
@Component
export struct PageThemeSettings {
    @State selectIndex: number = -1
    @State customColor: string = "#ffffff"
    private scaleSize = 1.25
    private selectorDialogController = new CustomDialogController({
        builder: CustomThemeDialog({
            onColorSelect: (color) => {
                this.customColor = color
                this.selectIndex = -1
            }
        }),
        autoCancel: true,
        customStyle: true
    })

    pageTransition() {
        PageTransitionEnter({ duration: 300 }).opacity(0).scale({ x: 0.75, y: 0.75 })
        PageTransitionExit({ duration: 300 }).opacity(0).scale({ x: 0.75, y: 0.75 })
    }

    aboutToAppear() {
        let params = router.getParams() as Record<string, string>
        if (params) {
            this.customColor = params.THEME_COLOR
        }
        Logger.d(TAG, "router data = " + JSON.stringify(params))
    }

    @Styles
    normalStyles(){
        .backgroundColor(this.customColor)
        .scale({ x: 1, y: 1 })
        .shadow({
            radius: UIConfig.DIMENSION_NORMAL_SHADOW,
            color: "#ccb8b8b8",
            offsetY: UIConfig.DIMENSION_OFFSET_SHADOW
        })
    }

    @Styles
    pressedStyles(){
        .backgroundColor(dimColor(this.customColor))
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
                .fontColor(this.customColor)
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
                                this.customColor = THEME_COLOR[this.selectIndex]
                            })
                    })
                    Image($r("app.media.ic_color_wheel"))
                        .objectFit(ImageFit.Contain)
                        .width(40)
                        .height(40)
                        .margin({ left: 20 })
                        .border({ radius: 100, color: Color.Black, width: this.selectIndex == -1 ? 1 : 0 })
                        .scale({
                            x: this.selectIndex == -1 ? this.scaleSize : 1,
                            y: this.selectIndex == -1 ? this.scaleSize : 1
                        })
                        .onClick(() => {
                            this.selectorDialogController.open()
                        })
                }.justifyContent(FlexAlign.SpaceEvenly)
            }
            .scrollBar(BarState.Off)
            .scrollable(ScrollDirection.Horizontal)
            .height(64)
            .width("100%")
            .margin({ top: 48 })
            .align(Alignment.Center)

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
            Logger.d(TAG, "current colorPrimary = " + this.customColor)
            for (let i = 0; i < THEME_COLOR.length; i++) {
                if (this.customColor == THEME_COLOR[i]) {
                    this.selectIndex = i
                    break
                }
            }
        })
    }

    private async setTheme() {
        let theme = new Theme(this.customColor)
        ThemeManager.get().updateTheme(theme)
        await ThemeManager.get().saveTheme(theme)
        router.back()
    }
}