import { UIConfig } from '../config/UIConfig'
import { dimColor } from '../extensions/Extensions'

@Preview
@Component
export struct Fab {
    text: ResourceStr = ""
    textSize: number = 12
    textColor: ResourceColor = "#ffffff"
    color: number | string = "#ffc5c5c5"
    onAction: (event: ClickEvent) => void = (_: ClickEvent) => {
    }
    marginSize: Padding | Length = 0
    dimColor: number = 0x000000
    w: Length = 150
    h: Length = 50

    aboutToAppear() {
        this.dimColor = dimColor(this.color, 0.95)
    }

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
        .backgroundColor(this.dimColor)
        .scale({ x: 0.95, y: 0.95 })
        .shadow({
            radius: UIConfig.DIMENSION_PRESS_SHADOW,
            color: "#ccb8b8b8",
            offsetY: UIConfig.DIMENSION_OFFSET_SHADOW
        })
    }

    build() {
        Text(this.text)
            .fontSize(this.textSize)
            .fontColor(this.textColor)
            .textAlign(TextAlign.Center)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin(this.marginSize)
            .border({ radius: UIConfig.DIMENSION_CORNER })
            .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
            })
            .onClick((event) => {
                this.onAction?.(event)
            })
            .width(this.w)
            .height(this.h)
    }
}