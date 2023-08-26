import { dimColor } from '../extensions/Extensions'

@Preview
@Component
export struct Fab {
    text: ResourceStr
    textSize: number
    textColor: ResourceColor = "#ffffff"
    color: number | string = "#ffc5c5c5"
    onAction: (event: ClickEvent) => void
    marginSize: Padding | Length
    dimColor: number
    w: Length = 150
    h: Length = 50

    aboutToAppear() {
        this.dimColor = dimColor(this.color, 0.95)
    }

    @Styles
    normalStyles(){
        .backgroundColor(this.color)
        .shadow({ radius: 12, color: "#ccb8b8b8", offsetY: 8 })
    }

    @Styles
    pressedStyles(){
        .backgroundColor(this.dimColor)
        .shadow({ radius: 6, color: "#ccb8b8b8", offsetY: 8 })
    }

    build() {
        Text(this.text)
            .fontSize(this.textSize)
            .fontColor(this.textColor)
            .textAlign(TextAlign.Center)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin(this.marginSize)
            .border({ radius: 4 })
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