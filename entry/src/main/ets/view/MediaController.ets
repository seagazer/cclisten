import { PlayModeController } from '../player/PlayModeController'
import { LoopMode } from '../player/LoopMode'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { APP_THEME, MEDIA_SESSION_PLAYING_STATE } from '../extensions/LiveData'
import { UIConfig } from '../config/UIConfig'

@Extend(Image)
function btnStyle(size: Length, padding: Length) {
    .width(size)
    .height(size)
    .padding(padding)
}

@Preview
@Component
export struct MediaController {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_PLAYING_STATE) isPlaying: boolean = false
    @State playModeIcon: Resource = PlayModeController.get().getIcon()
    actionPlayOrPause: () => void = () => {
    }
    actionPlayNext: () => void = () => {
    }
    actionPlayPre: () => void = () => {
    }
    actionPlayMode: () => void = () => {
    }
    actionPlaylist: () => void = () => {
    }
    onModeChanged: (mode: LoopMode) => void = (mode:LoopMode) => {
    }

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

    aboutToAppear() {
        PlayModeController.get().onModeChanged = (mode) => {
            this.playModeIcon = PlayModeController.get().getIcon()
            this.onModeChanged?.(mode)
        }
    }

    build() {
        Row() {
            // loop mode
            Image(this.playModeIcon)
                .btnStyle(48, 12)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    let mode = PlayModeController.get().change()
                    this.playModeIcon = PlayModeController.get().getIcon()
                    this.onModeChanged?.(mode)
                })
            // play pre
            Image($r('app.media.baseline_skip_previous_24'))
                .btnStyle(48, 6)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayPre?.()
                })
            // play & pause
            Image(this.isPlaying ? $r('app.media.baseline_pause_circle_24') : $r('app.media.baseline_play_circle_24'))
                .btnStyle(76, 2)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .fillColor(this.theme.colorPrimary)
                .onClick(() => {
                    this.actionPlayOrPause?.()
                })
            // play next
            Image($r('app.media.baseline_skip_next_24'))
                .btnStyle(48, 6)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayNext?.()
                })
            // play list
            Image($r('app.media.baseline_list_24'))
                .btnStyle(48, 12)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlaylist?.()
                })
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .margin({ top: 16 })
    }
}