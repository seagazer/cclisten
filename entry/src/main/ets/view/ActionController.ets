import { DEFAULT_THEME, Theme } from '../theme/Theme'

@Extend(Image) function playBtnStyle(size: Length, padding: Length, margin: Length, themeColor: string) {
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
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    actionPlayOrPause: () => void
    actionPlayNext: () => void
    actionPlayPre: () => void
    @Link isPlaying: boolean

    @Styles pressedStyles() {
        .backgroundColor(this.theme.colorAction)
    }

    @Styles normalStyles() {
        .backgroundColor(null)
    }

    build() {
        Row() {
            Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
                .playBtnStyle(72, 4, 0, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayOrPause?.()
                })
            Image($r('app.media.ic_pre'))
                .playBtnStyle(48, 4, 16, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayPre?.()
                })
            Image($r('app.media.ic_next'))
                .playBtnStyle(48, 4, 0, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayNext?.()
                })
        }
        .width('100%')
        .margin({ top: 48 })
    }
}