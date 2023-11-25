import { LoopMode } from '../player/LoopMode'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { APP_THEME } from '../extensions/LiveData'
import { StatefulImageButton } from './StatefulImageButton'
import { StatelessImageButton } from './StatelessImageButton'

@Component
export struct MediaController {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @Link @Watch("playStateChanged") isPlaying: boolean
    @Link loopMode: LoopMode
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

    playStateChanged() {
        if (this.isPlaying) {
            this.playIcon = $r('app.media.ic_pause')
        } else {
            this.playIcon = $r('app.media.ic_play')
        }
    }

    private changedLoopMode() {
        if (this.loopMode == LoopMode.SHUFFLE) {
            this.loopMode = LoopMode.LOOP_ALL
            this.loopIcon = $r("app.media.ic_public_list_cycle")
        } else if (this.loopMode == LoopMode.LOOP_ALL) {
            this.loopMode = LoopMode.LOOP_SINGLE
            this.loopIcon = $r("app.media.ic_public_single_cycle")
        } else if (this.loopMode == LoopMode.LOOP_SINGLE) {
            this.loopMode = LoopMode.SHUFFLE
            this.loopIcon = $r("app.media.ic_public_random")
        }
    }

    build() {
        Row() {
            // loop mode
            StatefulImageButton({
                image: $loopIcon
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
                image: $playIcon,
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
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .margin({ top: 16 })
    }
}