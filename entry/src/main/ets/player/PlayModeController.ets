import { LoopMode } from './LoopMode'

/**
 * Author: seagazer
 * Date: 2023/6/4
 */
export class PlayModeController {
    private mode: LoopMode = LoopMode.LOOP_ALL
    private playModeIcon: Resource = $r("app.media.baseline_repeat_24")
    private static sInstance = new PlayModeController()
    onModeChanged: (mode: LoopMode) => void

    private constructor() {
    }

    public static get(): PlayModeController {
        return this.sInstance
    }


    change(): LoopMode {
        if (this.mode == LoopMode.SHUFFLE) {
            this.mode = LoopMode.LOOP_ALL
        } else if (this.mode == LoopMode.LOOP_ALL) {
            this.mode = LoopMode.LOOP_SINGLE
        } else if (this.mode == LoopMode.LOOP_SINGLE) {
            this.mode = LoopMode.SHUFFLE
        }
        this.onModeChanged?.(this.mode)
        return this.mode
    }

    getIcon(): Resource {
        switch (this.mode) {
        case LoopMode.LOOP_SINGLE:
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

    setCurrentMode(mode: LoopMode) {
        this.mode = mode
        this.onModeChanged?.(this.mode)
    }
}