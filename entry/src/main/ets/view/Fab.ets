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

    aboutToAppear() {
        this.dimColor = dimColor(this.color, 0.8)
    }

    @Styles
    normalStyles(){
        .backgroundColor(this.color)
        .shadow({ radius: 12, color: "#cc3a3a3a", offsetY: 4 })
    }

    @Styles
    pressedStyles(){
        .backgroundColor(this.dimColor)
        .shadow({ radius: 6, color: "#ff3a3a3a", offsetY: 4 })
    }

    build() {
        Text(this.text)
            .fontSize(this.textSize)
            .fontColor(this.textColor)
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
    }
}