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
            Image(this.loopMode == LoopMode.LOOP_ALL ? $r("app.media.ic_public_list_cycle") :
                this.loopMode == LoopMode.SHUFFLE ? $r("app.media.ic_public_random") : $r("app.media.ic_public_single_cycle"))
                .btnStyle(48, 6)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.changedLoopMode()
                })
            // play pre
            Image($r('app.media.ic_public_play_last'))
                .btnStyle(48, 6)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayPre?.()
                })
            // play & pause
            Image(this.isPlaying ? $r('app.media.ic_pause') : $r('app.media.ic_play'))
                .btnStyle(72, 2)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .fillColor(this.theme.colorPrimary)
                .onClick(() => {
                    this.actionPlay?.()
                })
            // play next
            Image($r('app.media.ic_public_play_next'))
                .btnStyle(48, 6)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .onClick(() => {
                    this.actionPlayNext?.()
                })
            // playlist
            Image($r("app.media.ic_public_view_list"))
                .btnStyle(48, 6)
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