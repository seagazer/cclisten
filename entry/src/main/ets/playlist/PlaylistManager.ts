import { Song } from '../bean/Song'
import { LiveData, MEDIA_SESSION_PLAYLIST } from '../extensions/LiveData'
import { Logger } from '../extensions/Logger'
import { LoopMode } from '../player/LoopMode'
import { PlaylistDb } from './PlaylistDb'
import common from '@ohos.app.ability.common'


const TAG = "[PlaylistManager]"


/**
 * The manager to manage a playlist of user.
 *
 * Author: seagazer
 * Date: 2023/6/4
 */
export class PlaylistManager {
    private static sInstance: PlaylistManager = null
    private songList = new Array<Song>()
    private currentIndex = 0
    private playlistDb: PlaylistDb

    private constructor() {
        this.playlistDb = new PlaylistDb()
    }

    static get(): PlaylistManager {
        if (!this.sInstance) {
            this.sInstance = new PlaylistManager()
        }
        return this.sInstance
    }

    updateCurrentSong(song: Song) {
        let index = -1
        for (let i = 0;i < this.songList.length; i++) {
            let cur = this.songList[i]
            if (cur.url == song.url) {
                index = i
                break
            }
        }
        this.currentIndex = index
        Logger.d(TAG, "current index= " + this.currentIndex)
    }

    async initFromDb(context: common.Context) {
        try {
            await this.playlistDb.init(context)
            let songList = await this.playlistDb.getPlaylist()
            if (songList) {
                this.songList = songList
                this.onPlaylistChanged()
            }
        } catch (err) {
            Logger.e(TAG, "init playlist from db error= " + JSON.stringify(err))
        }
    }

    add(song: Song) {
        this.songList.push(song)
        this.onPlaylistChanged()
        this.playlistDb.addSong(song)
    }

    addList(songs: Array<Song>) {
        this.songList = this.songList.concat(songs)
        this.playlistDb.addSongList(songs)
        this.onPlaylistChanged()
    }

    remove(song: Song) {
        let index = this.songList.indexOf(song)
        if (index >= 0) {
            this.songList.splice(index, 1)
            this.playlistDb.removeSong(song)
            this.onPlaylistChanged()
        }
    }

    private onPlaylistChanged() {
        LiveData.setValue(MEDIA_SESSION_PLAYLIST, this.songList)
    }

    getSong(index: number): Song {
        if (index < 0 || index > this.songList.length - 1) {
            throw new Error("[Overflow] the index is out of range, this playlist size is " + this.songList.length + ", index is " + index)
        }
        return this.songList[index]
    }

    getIndex(song: Song): number {
        let index = this.songList.indexOf(song)
        Logger.d(TAG, "song index= " + index)
        return index
    }

    getPlayingIndex(): number {
        return this.currentIndex
    }

    getNext(mode: LoopMode): Song {
        switch (mode) {
            case LoopMode.LOOP:
                return this.songList[this.currentIndex]
            case LoopMode.SHUFFLE:
            // todo get the shuffle next
                let random = Math.round(Math.random() * this.songList.length)
                return this.songList[random]
            case LoopMode.PLAYLIST_LOOP:
                let nextIndex = ++this.currentIndex
                if (nextIndex > this.songList.length - 1) {
                    nextIndex = 0
                }
                Logger.d(TAG, "get next index= " + nextIndex)
                return this.songList[nextIndex]
        }
    }


    getPre(mode: LoopMode): Song {
        switch (mode) {
            case LoopMode.LOOP:
                return this.songList[this.currentIndex]
            case LoopMode.SHUFFLE:
            // todo get the shuffle pre
                let random = Math.round(Math.random() * this.songList.length)
                return this.songList[random]
            case LoopMode.PLAYLIST_LOOP:
                let preIndex = --this.currentIndex
                if (preIndex < 0) {
                    preIndex = this.songList.length - 1
                }
                Logger.d(TAG, "get pre index= " + preIndex)
                return this.songList[preIndex]
        }
    }

    size(): number {
        return this.songList.length
    }

    current(): Song {
        return this.songList[this.currentIndex]
    }
}