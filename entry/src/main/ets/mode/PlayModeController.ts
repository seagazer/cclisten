import { PlayerMode } from './PlayerMode'


export class PlayModeController {
    private mode: PlayerMode = PlayerMode.PLAYLIST_LOOP
    private index = 0
    private max = 3

    change(): PlayerMode {
        this.index++
        let order = this.index % this.max
        if (order == 0) {
            this.mode = PlayerMode.PLAYLIST_LOOP
        } else if (order == 1) {
            this.mode = PlayerMode.LOOP
        } else {
            this.mode = PlayerMode.SHUFFLE
        }
        return this.mode
    }

    getCurrentMode(): PlayerMode {
        return this.mode
    }
}