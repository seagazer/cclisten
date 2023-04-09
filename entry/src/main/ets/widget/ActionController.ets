@Extend(Image) function playBtnStyle(size: Length, padding: Length, margin: Length, themeColor: ResourceColor) {
    .width(size)
    .aspectRatio(1)
    .padding(padding)
    .margin({ left: margin, right: margin })
    .colorBlend(themeColor)
    .border({
        radius: size,
        color: themeColor,
        width: 2
    })
}

@Component
export struct ActionController {
    private themeColor: ResourceColor = "#000000"
    actionPlayOrPause: () => void
    actionPlayNext: () => void
    actionPlayPre: () => void
    @Link isPlaying: boolean

    @Styles pressedStyles() {
        .backgroundColor("#cce2e2e2")
    }

    build() {
        Row() {
            Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
                .playBtnStyle(72, 4, 0, this.themeColor)
                .stateStyles({
                    pressed: this.pressedStyles
                })
                .onClick(() => {
                    this.actionPlayOrPause?.()
                })
            Image($r('app.media.ic_pre'))
                .playBtnStyle(48, 4, 16, this.themeColor)
                .stateStyles({
                    pressed: this.pressedStyles
                })
                .onClick(() => {
                    this.actionPlayPre?.()
                })
            Image($r('app.media.ic_next'))
                .playBtnStyle(48, 4, 0, this.themeColor)
                .stateStyles({
                    pressed: this.pressedStyles
                })
                .onClick(() => {
                    this.actionPlayNext?.()
                })
        }
        .width('100%')
        .margin({ top: 48 })
    }
}