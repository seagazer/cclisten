import { LoopMode } from './LoopMode'

/**
 * Author: seagazer
 * Date: 2023/6/4
 */
export class PlayModeController {
    private mode: LoopMode = LoopMode.PLAYLIST_LOOP
    private playModeIcon: Resource = $r("app.media.baseline_repeat_24")
    private index = 0
    private max = 3

    change(): LoopMode {
        this.index++
        let order = this.index % this.max
        if (order == 0) {
            this.mode = LoopMode.PLAYLIST_LOOP
        } else if (order == 1) {
            this.mode = LoopMode.LOOP
        } else {
            this.mode = LoopMode.SHUFFLE
        }
        return this.mode
    }

    getIcon(): Resource {
        switch (this.mode) {
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
        return this.playModeIcon
    }

    getCurrentMode(): LoopMode {
        return this.mode
    }
}