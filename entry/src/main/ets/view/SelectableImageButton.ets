import { UIConfig } from '../config/UIConfig'
import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'

@Extend(Image)
function btnStyle(width: Length, height: Length, padding: Length) {
    .width(width)
    .height(height)
    .padding(padding)
}

@Component
export struct SelectableImageButton {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @Link image: Resource
    w: Length = 42
    h: Length = 42
    edge: Length = 6
    @Link isSelected: boolean

    @Styles
    pressedStyles() {
        .border({ radius: UIConfig.DIMENSION_CIRCLE })
        .backgroundColor(this.theme.colorAction)
    }

    @Styles
    normalStyles() {
        .border({ radius: UIConfig.DIMENSION_CIRCLE })
        .backgroundColor(null)
    }

    build() {
        if (this.isSelected) {
            Image(this.image)
                .btnStyle(this.w, this.h, this.edge)
                .fillColor(this.theme.colorPrimary)
                .animation({ duration: UIConfig.ANIM_DURATION })
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
        } else {
            Image(this.image)
                .btnStyle(this.w, this.h, this.edge)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
        }
    }
}