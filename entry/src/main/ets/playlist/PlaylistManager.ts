import { Song } from '../bean/Song'

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

    add(song: Song) {
        this.list.push(song)
    }

    addList(songs: Array<Song>) {
        this.list = this.list.concat(songs)
    }

    remove() {
    }

    getByIndex(index: number): Song {
        if (index < 0 || index > this.list.length - 1) {
            throw new Error("[Overflow] the index is out of range, this playlist size is " + this.list.length + ", index is " + index)
        }
        return this.list[index]
    }

    getPlayingIndex(): number {
        return this.currentIndex
    }

    getNext(): Song {
        return null
    }


    getPre(): Song {
        return null
    }

    size(): number {
        return this.list.length
    }

    getCurrent(): Song {
        return this.list[this.currentIndex]
    }
}