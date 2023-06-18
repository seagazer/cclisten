import { Song } from '../bean/Song'
import { Logger } from '../extensions/Logger'
import { LoopMode } from '../player/LoopMode'


const TAG = "[PlaylistManager]"


/**
 * The manager to manage a playlist of user.
 *
 * Author: seagazer
 * Date: 2023/6/4
 */
export class PlaylistManager {
    private static sInstance: PlaylistManager = null
    private list = new Array<Song>()
    private currentIndex = 0

    private constructor() {
    }

    static get(): PlaylistManager {
        if (!this.sInstance) {
            this.sInstance = new PlaylistManager()
        }
        return this.sInstance
    }

    updateCurrentSong(song: Song) {
        let index = this.list.indexOf(song)
        this.currentIndex = index
    }

    add(song: Song) {
        // todo update list index
        this.list.push(song)
    }

    addList(songs: Array<Song>) {
        // todo update list index
        this.list = this.list.concat(songs)
    }

    remove() {
        // todo update list index
    }

    getSong(index: number): Song {
        if (index < 0 || index > this.list.length - 1) {
            throw new Error("[Overflow] the index is out of range, this playlist size is " + this.list.length + ", index is " + index)
        }
        return this.list[index]
    }

    getIndex(song: Song): number {
        let index = this.list.indexOf(song)
        Logger.d(TAG, "song index= " + index)
        return index
    }

    getPlayingIndex(): number {
        return this.currentIndex
    }

    getNext(mode: LoopMode): Song {
        let nextIndex = ++this.currentIndex
        if (nextIndex > this.list.length - 1) {
            nextIndex = 0
        }
        Logger.d(TAG, "get next index= " + nextIndex)
        return this.list[nextIndex]
    }


    getPre(mode: LoopMode): Song {
        let preIndex = --this.currentIndex
        if (preIndex < 0) {
            preIndex = this.list.length - 1
        }
        Logger.d(TAG, "get pre index= " + preIndex)
        return this.list[preIndex]
    }

    size(): number {
        return this.list.length
    }

    current(): Song {
        return this.list[this.currentIndex]
    }
}