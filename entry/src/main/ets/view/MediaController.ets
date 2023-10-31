import { LoopMode } from '../player/LoopMode'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { APP_THEME, LiveData, MEDIA_SESSION_LOOP_MODE, MEDIA_SESSION_PLAYING_STATE } from '../extensions/LiveData'
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
    @StorageLink(MEDIA_SESSION_LOOP_MODE) loopMode: LoopMode = LoopMode.LOOP_ALL
    actionPlay = () => {
    }
    actionPlayNext = () => {
    }
    actionPlayPre = () => {
    }
    actionPlaylist = () => {
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

    private changedLoopMode() {
        if (this.loopMode == LoopMode.SHUFFLE) {
            this.loopMode = LoopMode.LOOP_ALL
        } else if (this.loopMode == LoopMode.LOOP_ALL) {
            this.loopMode = LoopMode.LOOP_SINGLE
        } else if (this.loopMode == LoopMode.LOOP_SINGLE) {
            this.loopMode = LoopMode.SHUFFLE
        }
        LiveData.setValue<LoopMode>(MEDIA_SESSION_LOOP_MODE, this.loopMode)
    }

    build() {
        Row() {
            // loop mode
            Image(this.loopMode == LoopMode.LOOP_ALL ? $r("app.media.baseline_repeat_24") :
                this.loopMode == LoopMode.SHUFFLE ? $r("app.media.baseline_shuffle_24") : $r("app.media.baseline_repeat_one_24"))
                .btnStyle(48, 12)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.changedLoopMode()
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
                    this.actionPlay?.()
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
            // playlist
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