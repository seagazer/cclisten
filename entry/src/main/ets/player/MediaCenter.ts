/**
 * The media center is a core module to manager all the play action of media player.
 */
import { LoopMode } from '../mode/LoopMode'

export class MediaCenter {
    private curIndex = 0
    private loopMode: LoopMode


    setPlayMode(mode: LoopMode) {
        this.loopMode = mode
    }

    playPre() {

    }


    playNext() {

    }
}