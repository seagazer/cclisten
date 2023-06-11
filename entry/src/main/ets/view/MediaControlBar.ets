import { PlayModeController } from '../mode/PlayModeController'
import { LoopMode } from '../mode/LoopMode'
import { DEFAULT_THEME, Theme } from '../theme/Theme'

@Extend(Image) function btnStyle(size: Length, padding: Length) {
    .width(size)
    .height(size)
    .padding(padding)
}

@Preview
@Component
export struct MediaControlBar {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    actionPlayOrPause: () => void
    actionPlayNext: () => void
    actionPlayPre: () => void
    actionPlayMode: () => void
    actionLyric: () => void
    onModeChanged: (mode: LoopMode) => void
    @Link isPlaying: boolean
    private playModeController: PlayModeController = new PlayModeController()
    @State playModeIcon: Resource = $r("app.media.baseline_repeat_24")

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
            Image(this.playModeIcon)
                .btnStyle(48, 12)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    let mode = this.playModeController.change()
                    this.onModeChanged?.(mode)
                    switch (mode) {
                        case LoopMode.LOOP:
                            this.playModeIcon = $r("app.media.baseline_repeat_one_24")
                            break;
                        case LoopMode.SHUFFLE:
                            this.playModeIcon = $r("app.media.baseline_shuffle_24")
                            break;
                        default:
                            this.playModeIcon = $r("app.media.baseline_repeat_24")
                            break;
                    }
                })
            Image($r('app.media.baseline_skip_previous_24'))
                .btnStyle(48, 6)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayPre?.()
                })

            Image(this.isPlaying ? $r('app.media.baseline_pause_circle_24') : $r('app.media.baseline_play_circle_24'))
                .btnStyle(72, 2)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .fillColor(this.theme.colorPrimary)
                .onClick(() => {
                    this.actionPlayOrPause?.()
                })

            Image($r('app.media.baseline_skip_next_24'))
                .btnStyle(48, 6)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayNext?.()
                })
            Image($r('app.media.baseline_list_24'))
                .btnStyle(48, 12)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionLyric?.()
                })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .margin({ top: 16 })
        .padding({ left: 16, right: 16 })
    }
}