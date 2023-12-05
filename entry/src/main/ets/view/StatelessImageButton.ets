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
export struct StatelessImageButton {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    image: ResourceStr = ""
    widthSize: Length = 42
    heightSize: Length = 42
    paddingSize: Length = 6
    isFillColor: boolean = false

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
        if (this.isFillColor) {
            Image(this.image)
                .btnStyle(this.widthSize, this.heightSize, this.paddingSize)
                .fillColor(this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
        } else {
            Image(this.image)
                .btnStyle(this.widthSize, this.heightSize, this.paddingSize)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
        }
    }
}