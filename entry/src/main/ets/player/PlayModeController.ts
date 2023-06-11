import { LoopMode } from './LoopMode'


export class PlayModeController {
    private mode: LoopMode = LoopMode.PLAYLIST_LOOP
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

    getCurrentMode(): LoopMode {
        return this.mode
    }
}