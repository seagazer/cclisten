import { PlayModeController } from '../player/PlayModeController'
import { LoopMode } from '../player/LoopMode'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { APP_THEME, MEDIA_SESSION_PLAYING_STATE } from '../extensions/LiveData'

@Extend(Image) function btnStyle(size: Length, padding: Length) {
    .width(size)
    .height(size)
    .padding(padding)
}

@Preview
@Component
export struct MediaController {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_PLAYING_STATE) isPlaying: boolean = false
    private playModeController: PlayModeController = new PlayModeController()
    @State playModeIcon: Resource = this.playModeController.getIcon()
    actionPlayOrPause: () => void
    actionPlayNext: () => void
    actionPlayPre: () => void
    actionPlayMode: () => void
    actionLyric: () => void
    onModeChanged: (mode: LoopMode) => void

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
                    this.playModeIcon = this.playModeController.getIcon()
                    this.onModeChanged?.(mode)
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