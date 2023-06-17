import { CcPlayer, MediaSourceFactory, PlayerState, PlayerType } from '@seagazer/ccplayer'
import { Song } from '../bean/Song'
import { parseUri } from '../extensions/Extensions'
import { syncLiveData } from '../extensions/LiveData'
import { Logger } from '../extensions/Logger'
import { PlaylistManager } from '../playlist/PlaylistManager'
import { LoopMode } from './LoopMode'

const TAG = "MediaSession"

export const MEDIA_SESSION_PLAYING_STATE = "IS_PLAYING"

export const MEDIA_SESSION_POSITION = "CUR_POSITION"

export const MEDIA_SESSION_DURATION = "TOTAL_DURATION"

export const MEDIA_SESSION_TITLE = "TITLE"

export const MEDIA_SESSION_ARTIST = "ARTIST"

export const MEDIA_SESSION_CURRENT_SONG = "CURRENT_SONG"

export const MEDIA_SESSION_FILE_LIST = "FILE_LIST"

/**
 * Author: seagazer
 * Date: 2023/6/17
 */
export class MediaSession {
    private static sInstance: MediaSession = null
    private player: CcPlayer = null
    private isSeeking = false
    private loopMode: LoopMode = LoopMode.PLAYLIST_LOOP
    private playlist: PlaylistManager = null
    private onProgressList: Array<(position: number) => void> = new Array()
    private onPrepareList: Array<() => void> = new Array()

    private progressChangedListener = (position: number) => {
        if (!this.isSeeking) {
            syncLiveData(MEDIA_SESSION_POSITION, position)
            this.onProgressList.forEach((callback) => {
                callback(position)
            })
        }
    }
    private prepareListener = () => {
        this.isSeeking = false
        this.onPrepareList.forEach((callback) => {
            callback()
        })
    }
    private completedListener = () => {
        // todo
        switch (this.loopMode) {
            case LoopMode.PLAYLIST_LOOP:
                break
            case LoopMode.LOOP:
                break
            case LoopMode.SHUFFLE:
                break
        }
    }
    private seekChangedListener = () => {
        this.isSeeking = false
    }
    private stateChangedListener = (newState: PlayerState) => {
        if (newState == PlayerState.STATE_STARTED) {
            syncLiveData(MEDIA_SESSION_PLAYING_STATE, true)
        } else {
            syncLiveData(MEDIA_SESSION_PLAYING_STATE, false)
        }
    }

    private constructor() {
        this.player = CcPlayer.create(PlayerType.AUDIO)
        this.player
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnPreparedListener(this.prepareListener)
            .addOnCompletionListener(this.completedListener)
            .addOnSeekChangedListener(this.seekChangedListener)
            .addOnStateChangedListener(this.stateChangedListener)
    }

    public static get(): MediaSession {
        if (!this.sInstance) {
            this.sInstance = new MediaSession()
        }
        return this.sInstance
    }

    onProgress(callback: (position: number) => void) {
        this.onProgressList.push(callback)
    }

    onPrepare(callback: () => void) {
        this.onPrepareList.push(callback)
    }

    setPlaylistManager(playlist: PlaylistManager) {
        this.playlist = playlist
    }

    setPlayMode(mode: LoopMode) {
        this.loopMode = mode
    }

    isPlaying(): boolean {
        return this.player.isPlaying()
    }

    start() {
        this.player.start()
    }

    pause() {
        this.player.pause()
    }

    seekTo(value: number) {
        this.isSeeking = true
        this.player.seekTo(value)
    }

    getDuration(): number {
        return this.player.getDuration()
    }

    playNext() {
        let next = this.playlist.getNext()
        this.playSong(next)
    }

    playPre() {
        let pre = this.playlist.getNext()
        this.playSong(pre)
    }

    async playSong(song: Song) {
        syncLiveData(MEDIA_SESSION_TITLE, song.title)
        syncLiveData(MEDIA_SESSION_ARTIST, song.artist)
        syncLiveData(MEDIA_SESSION_DURATION, song.duration)
        let fd = await parseUri(song.url)
        let source = MediaSourceFactory.createUrl("fd://" + fd, song.title)
        this.player.setMediaSource(source, () => {
            this.start()
        })
    }

    release() {
        this.player
            .removeOnPreparedListener(this.prepareListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnCompletionListener(this.completedListener)
            .release()
    }
}
