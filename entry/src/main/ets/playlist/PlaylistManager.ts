import { Song } from '../bean/Song'
import { LiveData, MEDIA_SESSION_CURRENT_SONG, MEDIA_SESSION_PLAYLIST } from '../extensions/LiveData'
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
    private shuttleList = new Array<Song>()
    private playingIndex = 0
    private playingSong: Song = null
    private playlistDb: PlaylistDb
    private loopMode = LoopMode.LOOP_ALL

    private constructor() {
        this.playlistDb = new PlaylistDb()
    }

    static get(): PlaylistManager {
        if (!this.sInstance) {
            this.sInstance = new PlaylistManager()
        }
        return this.sInstance
    }

    setLoopMode(mode: LoopMode) {
        this.loopMode = mode
        if (mode == LoopMode.SHUFFLE) {
            this.shuttleList = []
            this.songList.forEach((song) => {
                this.shuttleList.push(song)
            })
            this.shuttleSort(this.shuttleList)
        }
        this.onPlaylistChanged()
    }

    setPlayingSong(song: Song) {
        this.playingSong = song
        this.updateIndex()
        LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, song)
        Logger.d(TAG, "current index= " + this.playingIndex)
    }

    async init(context: common.Context) {
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

    updateSong(song: Song) {
        this.playlistDb.update(song)
    }

    addList(songs: Array<Song>) {
        this.songList = this.songList.concat(songs)
        this.playlistDb.addSongList(songs)
        this.onPlaylistChanged()
    }

    remove(song: Song) {
        let index = this.indexOf(song, this.songList)
        let index2 = this.indexOf(song, this.shuttleList)
        Logger.d(TAG, "remove " + index + ", " + index2)
        if (index >= 0) {
            this.songList.splice(index, 1)
            this.shuttleList.splice(index2, 1)
            this.playlistDb.removeSong(song)
        }
        this.onPlaylistChanged()
    }

    private indexOf(song: Song, list: Array<Song>) {
        for (let i = 0; i < list.length; i++) {
            let url = list[i].url
            if (url == song.url) {
                return i
            }
        }
        return -1
    }

    private shuttleSort(list: Array<Song>) {
        list.sort(() => {
            return Math.random() - 0.5
        })
    }

    private onPlaylistChanged() {
        this.updateIndex()
        if (this.loopMode == LoopMode.SHUFFLE) {
            LiveData.setValue(MEDIA_SESSION_PLAYLIST, this.shuttleList)
        } else {
            LiveData.setValue(MEDIA_SESSION_PLAYLIST, this.songList)
        }
    }

    private updateIndex() {
        if (!this.playingSong) {
            return
        }
        let index = -1
        let list = this.loopMode == LoopMode.SHUFFLE ? this.shuttleList : this.songList
        for (let i = 0; i < list.length; i++) {
            let url = list[i].url
            if (url == this.playingSong.url) {
                index = i
                break
            }
        }
        this.playingIndex = index
    }

    getSong(index: number): Song {
        if (index < 0 || index > this.songList.length - 1) {
            throw new Error("[Overflow] the index is out of range, this playlist size is " + this.songList.length + ", index is " + index)
        }
        return this.songList[index]
    }

    getIndex(song: Song): number {
        let list = this.loopMode == LoopMode.SHUFFLE ? this.shuttleList : this.songList
        for (let i = 0; i < list.length; i++) {
            let url = list[i].url
            if (url == song.url) {
                return i
            }
        }
        return -1
    }

    getPlayingIndex(): number {
        return this.playingIndex
    }

    getNext(): Song {
        switch (this.loopMode) {
            case LoopMode.LOOP_SINGLE:
                if (this.playingSong) {
                    return this.playingSong
                } else {
                    let nextIndex = ++this.playingIndex
                    if (nextIndex > this.songList.length - 1) {
                        nextIndex = 0
                    }
                    Logger.d(TAG, "get next index= " + nextIndex)
                    return this.songList[nextIndex]
                }
            case LoopMode.SHUFFLE:
                let nextSIndex = ++this.playingIndex
                if (nextSIndex > this.shuttleList.length - 1) {
                    nextSIndex = 0
                }
                Logger.d(TAG, "get next shuttle index= " + nextSIndex)
                return this.shuttleList[nextSIndex]
            case LoopMode.LOOP_ALL:
                let nextIndex = ++this.playingIndex
                if (nextIndex > this.songList.length - 1) {
                    nextIndex = 0
                }
                Logger.d(TAG, "get next index= " + nextIndex)
                return this.songList[nextIndex]
        }
    }

    getPre(): Song {
        switch (this.loopMode) {
            case LoopMode.LOOP_SINGLE:
                return this.playingSong
            case LoopMode.SHUFFLE:
                let preSIndex = --this.playingIndex
                if (preSIndex < 0) {
                    preSIndex = this.shuttleList.length - 1
                }
                Logger.d(TAG, "get pre shuttle index= " + preSIndex)
                return this.shuttleList[preSIndex]
            case LoopMode.LOOP_ALL:
                let preIndex = --this.playingIndex
                if (preIndex < 0) {
                    preIndex = this.songList.length - 1
                }
                Logger.d(TAG, "get pre index= " + preIndex)
                return this.songList[preIndex]
        }
    }

    getFavouriteList(): Array<Song> {
        let favouriteList = this.songList.filter((song) => {
            return song.isFavourite == 1
        })
        return favouriteList
    }
}