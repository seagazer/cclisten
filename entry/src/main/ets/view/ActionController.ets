import { DEFAULT_THEME, Theme } from '../theme/Theme'

@Extend(Image) function playBtnStyle(size: Length, padding: Length, themeColor: string) {
    .width(size)
    .height(size)
    .padding(padding)
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
                .playBtnStyle(48, 12, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                })
            Image($r('app.media.baseline_skip_previous_24'))
                .playBtnStyle(48, 6, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayPre?.()
                })

            Image(this.isPlaying ? $r('app.media.baseline_pause_circle_24') : $r('app.media.baseline_play_circle_24'))
                .playBtnStyle(72, 2, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayOrPause?.()
                })
                .colorBlend(this.theme.colorPrimary)

            Image($r('app.media.baseline_skip_next_24'))
                .playBtnStyle(48, 6, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayNext?.()
                })
            Image($r('app.media.baseline_list_24'))
                .playBtnStyle(48, 12, this.theme.colorPrimary)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .margin({ top: 16 })
        .padding({ left: 16, right: 16 })
    }
}