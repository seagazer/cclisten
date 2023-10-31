import { DEFAULT_THEME } from '../theme/Theme'

@Component
export struct ExtImage {
    src: string | PixelMap | Resource
    widthSize: Length = 0
    heightSize: Length = 0
    paddingSize: Length | Padding = 0
    marginSize: Length | Padding = 0
    tintColor: ResourceColor = null
    onAction: (event: ClickEvent) => void
    borderOp: BorderOptions = null
    imageFit: ImageFit = ImageFit.Cover
    bg: ResourceColor
    asRatio: number = 0

    @Styles
    pressedStyles() {
        .backgroundColor(DEFAULT_THEME.colorAction)
    }

    @Styles
    normalStyles() {
        .backgroundColor(null)
    }

    build() {
        Image(this.src)
            .width(this.widthSize)
            .height(this.heightSize)
            .objectFit(this.imageFit)
            .padding(this.paddingSize)
            .margin(this.marginSize)
            .colorBlend(this.tintColor)
            .border(this.borderOp)
            .backgroundColor(this.bg)
            .aspectRatio(this.asRatio)
            .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
            })
            .onClick((event) => {
                this.onAction?.(event)
            })
        // .bindPopup(this.showPop, this.popupOp)
        // .bindMenu(this.menuContent)
    }
}