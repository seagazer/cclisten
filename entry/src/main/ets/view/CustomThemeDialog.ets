import { UIConfig } from '../config/UIConfig'
import { dimColor } from '../extensions/Extensions'
import { ColorWheelView } from './ColorWheelView'

@Preview
@CustomDialog
export struct CustomThemeDialog {
    controller: CustomDialogController
    onColorSelect: (color: string) => void = (color: string) => {
    }
    @State color: string = "#ffb3b3b3"

    @Styles
    normalStyles(){
        .backgroundColor(this.color)
        .scale({ x: 1, y: 1 })
        .shadow({
            radius: UIConfig.DIMENSION_NORMAL_SHADOW,
            color: "#ccb8b8b8",
            offsetY: UIConfig.DIMENSION_OFFSET_SHADOW
        })
    }

    @Styles
    pressedStyles(){
        .backgroundColor(dimColor(this.color))
        .scale({ x: 0.95, y: 0.95 })
        .shadow({
            radius: UIConfig.DIMENSION_PRESS_SHADOW,
            color: "#ccb8b8b8",
            offsetY: UIConfig.DIMENSION_OFFSET_SHADOW
        })
    }

    build() {
        Column() {
            ColorWheelView({
                radius: 120,
                selectorRadius: 6,
                selectorBorderColor: "#ffffff",
                onColorSelected: (color) => {
                    this.color = color
                }
            })
            Text("确定")
                .fontSize(UIConfig.FONT_BUTTON)
                .fontColor("#ffffff")
                .textAlign(TextAlign.Center)
                .width(150)
                .height(50)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .margin({ top: 32 })
                .border({ radius: 50 })
                .stateStyles({
                    normal: this.normalStyles,
                    pressed: this.pressedStyles
                })
                .onClick(() => {
                    this.onColorSelect(this.color)
                    this.controller.close()
                })
                .animation({
                    duration: UIConfig.ANIM_DURATION
                })
        }
        .padding(32)
        .width(400)
        .backgroundColor(Color.White)
        .border({ radius: UIConfig.DIMENSION_CORNER })
    }
}