import { UIConfig } from '../config/UIConfig'
import { dimColor } from '../extensions/Extensions'
import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'

@Preview
@Component
export struct Fab {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    text: ResourceStr = ""
    textSize: number = 12
    textColor: ResourceColor = "#ffffff"
    onAction: (event: ClickEvent) => void = (_: ClickEvent) => {
    }
    marginSize: Padding | Length = 0
    w: Length = 150
    h: Length = 50

    @Styles
    normalStyles(){
        .backgroundColor(this.theme.colorPrimary)
        .scale({ x: 1, y: 1 })
        .shadow({
            radius: UIConfig.DIMENSION_NORMAL_SHADOW,
            color: "#ccb8b8b8",
            offsetY: UIConfig.DIMENSION_OFFSET_SHADOW
        })
    }

    @Styles
    pressedStyles(){
        .backgroundColor(dimColor(this.theme.colorPrimary))
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
            .width(this.w)
            .height(this.h)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin(this.marginSize)
            .border({ radius: this.h })
            .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
            })
            .onClick((event) => {
                this.onAction?.(event)
            })
            .animation({
                duration: UIConfig.ANIM_DURATION
            })
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
    }
}