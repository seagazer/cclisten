import { CcPlayer, MediaSourceFactory, PlayerState, PlayerType } from '@seagazer/ccplayer'
import { Song } from '../bean/Song'
import { parseUri } from '../extensions/Extensions'
import {
    LiveData,
    MEDIA_SESSION_ARTIST,
    MEDIA_SESSION_CURRENT_SONG,
    MEDIA_SESSION_DURATION,
    MEDIA_SESSION_PLAYING_STATE,
    MEDIA_SESSION_POSITION,
    MEDIA_SESSION_TITLE
} from '../extensions/LiveData'
import { Logger } from '../extensions/Logger'
import { PlaylistManager } from '../playlist/PlaylistManager'
import { LoopMode } from './LoopMode'

const TAG = "[MediaSession]"

/**
 * Author: seagazer
 * Date: 2023/6/17
 */
export class MediaSession {
    private static sInstance: MediaSession = null
    private player: CcPlayer = null
    private isSeeking = false
    private loopMode: LoopMode = LoopMode.PLAYLIST_LOOP
    private playlist: PlaylistManager = PlaylistManager.get()
    private onProgressList: Array<(position: number) => void> = new Array()
    private onDataChangedList: Array<() => void> = new Array()

    private progressChangedListener = (position: number) => {
        if (!this.isSeeking) {
            LiveData.setValue(MEDIA_SESSION_POSITION, position)
            this.onProgressList.forEach((callback) => {
                callback(position)
            })
        }
    }
    private prepareListener = () => {
        this.isSeeking = false
    }
    private completedListener = () => {
        this.playNext()
    }
    private seekChangedListener = () => {
        this.isSeeking = false
    }
    private stateChangedListener = (newState: PlayerState) => {
        if (newState == PlayerState.STATE_STARTED) {
            LiveData.setValue(MEDIA_SESSION_PLAYING_STATE, true)
        } else {
            LiveData.setValue(MEDIA_SESSION_PLAYING_STATE, false)
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

    onSongChanged(callback: () => void) {
        this.onDataChangedList.push(callback)
    }

    setLoopMode(mode: LoopMode) {
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
        let next = this.playlist.getNext(this.loopMode)
        Logger.d(TAG, "play next= " + JSON.stringify(next))
        this.playSong(next)
    }

    playPre() {
        let pre = this.playlist.getPre(this.loopMode)
        Logger.d(TAG, "play pre= " + JSON.stringify(pre))
        this.playSong(pre)
    }

    async playSong(song: Song) {
        Logger.d(TAG, "start play= " + JSON.stringify(song))
        LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, song)
        LiveData.setValue(MEDIA_SESSION_TITLE, song.title)
        LiveData.setValue(MEDIA_SESSION_ARTIST, song.artist)
        LiveData.setValue(MEDIA_SESSION_DURATION, song.duration)
        this.playlist.updateCurrentSong(song)
        let fd = await parseUri(song.url)
        let source = MediaSourceFactory.createUrl("fd://" + fd, song.title)
        this.player.setMediaSource(source, () => {
            this.start()
        })
        this.onDataChangedList.forEach((callback) => {
            callback()
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
