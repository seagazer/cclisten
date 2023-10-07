/**
 * Author: seagazer
 * Date: 2023/10/7
 */
import { LoopMode } from '../player/LoopMode'
import { Song } from './Song'

export class History {
    loopMode: LoopMode
    song: Song

    constructor(loopMode: LoopMode, song: Song) {
        this.loopMode = loopMode
        this.song = song
    }
}