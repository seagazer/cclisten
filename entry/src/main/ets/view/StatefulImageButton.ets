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
export struct StatefulImageButton {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @Link image: Resource
    w: Length = 42
    h: Length = 42
    edge: Length = 6
    isFill: boolean = false

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
        if (this.isFill) {
            Image(this.image)
                .btnStyle(this.w, this.h, this.edge)
                .fillColor(this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
        } else {
            Image(this.image)
                .btnStyle(this.w, this.h, this.edge)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
        }
    }
}