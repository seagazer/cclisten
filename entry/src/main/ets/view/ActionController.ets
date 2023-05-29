import { DEFAULT_THEME, Theme } from '../theme/Theme'

@Extend(Image) function playBtnStyle(size: Length, margin: Length, themeColor: string) {
    .width(size)
    .height(size)
    .margin({ left: margin, right: margin })
    // .colorBlend(themeColor)
}

@Component
export struct ActionController {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    actionPlayOrPause: () => void
    actionPlayNext: () => void
    actionPlayPre: () => void
    @Link isPlaying: boolean

    @Styles pressedStyles() {
        .border({ radius: 200 })
        .backgroundColor(this.theme.colorAction)
    }

    @Styles normalStyles() {
        .border({ radius: 200 })
        .backgroundColor(null)
    }

    build() {
        Row() {
            Image($r('app.media.baseline_favorite_border_24'))
                .playBtnStyle(36, 0, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                })
            Image($r('app.media.baseline_skip_previous_24'))
                .playBtnStyle(36, 0, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayPre?.()
                })

            Image(this.isPlaying ? $r('app.media.baseline_pause_circle_24') : $r('app.media.baseline_play_circle_24'))
                .playBtnStyle(72, 0, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayOrPause?.()
                })
                .colorBlend(this.theme.colorPrimary)

            Image($r('app.media.baseline_skip_next_24'))
                .playBtnStyle(36, 0, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayNext?.()
                })
            Image($r('app.media.baseline_list_24'))
                .playBtnStyle(36, 0, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .margin({ top: 48 })
    }
}