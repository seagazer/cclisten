import { LoopMode } from '../player/LoopMode'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { APP_THEME } from '../extensions/LiveData'
import { StatefulImageButton } from './StatefulImageButton'
import { StatelessImageButton } from './StatelessImageButton'

@Component
export struct MediaController {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @Watch("playStateChanged") @Link isPlaying: boolean
    @Watch("loopModeChanged") @Link loopMode: LoopMode
    @State loopIcon: Resource = $r("app.media.ic_public_list_cycle")
    @State playIcon: Resource = $r("app.media.ic_play")
    actionPlay = () => {
    }
    actionPlayNext = () => {
    }
    actionPlayPre = () => {
    }
    actionPlaylist = () => {
    }

    aboutToAppear(){
        this.loopModeChanged()
    }

    playStateChanged() {
        if (this.isPlaying) {
            this.playIcon = $r('app.media.ic_pause')
        } else {
            this.playIcon = $r('app.media.ic_play')
        }
    }

    loopModeChanged() {
        switch (this.loopMode) {
            case LoopMode.LOOP_ALL:
                this.loopIcon = $r("app.media.ic_public_list_cycle")
                break
            case LoopMode.LOOP_SINGLE:
                this.loopIcon = $r("app.media.ic_public_single_cycle")
                break
            case LoopMode.SHUFFLE:
                this.loopIcon = $r("app.media.ic_public_random")
                break
        }
    }

    private changedLoopMode() {
        if (this.loopMode == LoopMode.SHUFFLE) {
            this.loopMode = LoopMode.LOOP_ALL
        } else if (this.loopMode == LoopMode.LOOP_ALL) {
            this.loopMode = LoopMode.LOOP_SINGLE
        } else if (this.loopMode == LoopMode.LOOP_SINGLE) {
            this.loopMode = LoopMode.SHUFFLE
        }
        this.loopModeChanged()
    }

    build() {
        Row() {
            // loop mode
            StatefulImageButton({
                image: this.loopIcon
            }).onClick(() => {
                this.changedLoopMode()
            })
            // play pre
            StatelessImageButton({
                image: $r("app.media.ic_public_play_last")
            }).onClick(() => {
                this.actionPlayPre()
            })
            // play & pause
            StatefulImageButton({
                w: 72,
                h: 72,
                edge: 2,
                image: this.playIcon,
                isFill: true
            }).onClick(() => {
                this.actionPlay()
            })
            // play next
            StatelessImageButton({
                image: $r("app.media.ic_public_play_next")
            }).onClick(() => {
                this.actionPlayNext()
            })
            // playlist
            StatelessImageButton({
                image: $r("app.media.ic_public_view_list")
            }).onClick(() => {
                this.actionPlaylist()
            })
        }
        .width('100%')
        .margin({ top: 8 })
        .justifyContent(FlexAlign.SpaceBetween)
    }
}