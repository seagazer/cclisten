import { Song } from '../bean/Song'

export class PlaylistManager {
    private list = new Array<Song>()
    private index = 0

    private constructor() {
    }

    static get(): PlaylistManager {
        if (!globalThis.playlist) {
            globalThis.playlist = new PlaylistManager()
        }
        return globalThis.playlist as PlaylistManager
    }

    add(song: Song) {
        this.list.push(song)
    }

    remove() {
    }

    getSong(index: number): Song {
        if (index < 0 || index > this.list.length - 1) {
            throw new Error("[Overflow] the index is out of range, this playlist size is " + this.list.length + ", index is " + index)
        }
        return this.list[index]
    }

    getCurrentIndex(): number {
        return this.index
    }

    size(): number {
        return this.list.length
    }

    getCurrent(): Song {
        return this.list[this.index]
    }
}