import { CcPlayer, MediaSourceFactory, PlayerState, PlayerType } from '@seagazer/ccplayer'
import { BackgroundTask } from '../extensions/BackgroundTask'
import { Song } from '../bean/Song'
import { parseUri } from '../extensions/Extensions'
import {
    LiveData,
    MEDIA_SESSION_CURRENT_SONG,
    MEDIA_SESSION_PLAYING_STATE,
    MEDIA_SESSION_POSITION,
} from '../extensions/LiveData'
import { Logger } from '../extensions/Logger'
import { PlaylistManager } from '../playlist/PlaylistManager'
import { LoopMode } from './LoopMode'
import common from '@ohos.app.ability.common'

import avSession from '@ohos.multimedia.avsession'

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
    private session: avSession.AVSession
    private context: common.Context

    private progressChangedListener = (position: number) => {
        if (!this.isSeeking) {
            LiveData.setValue(MEDIA_SESSION_POSITION, position)
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
        Logger.d(TAG, "player state changed= " + newState)
        if (newState == PlayerState.STATE_STARTED) {
            LiveData.setValue(MEDIA_SESSION_PLAYING_STATE, true)
            BackgroundTask.getInstance().startBackgroundTask()
        } else {
            LiveData.setValue(MEDIA_SESSION_PLAYING_STATE, false)
            if (newState == PlayerState.STATE_PAUSED ||
                newState == PlayerState.STATE_STOPPED ||
                newState == PlayerState.STATE_ERROR) {
                BackgroundTask.getInstance().stopBackgroundTask()
            }
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

    public initAvSession(context: common.Context) {
        this.context = context
        avSession.createAVSession(this.context, "ccplayer", "audio", (err, session) => {
            if (err) {
                Logger.e(TAG, "create av session error= " + JSON.stringify(err))
                return
            }
            this.session = session
        })
    }

    public static get(): MediaSession {
        if (!this.sInstance) {
            this.sInstance = new MediaSession()
        }
        return this.sInstance
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
        this.playlist.updateCurrentSong(song)
        let fd = await parseUri(song.url)
        let source = MediaSourceFactory.createUrl("fd://" + fd, song.title)
        this.player.setMediaSource(source, () => {
            this.start()
        })
    }

    release() {
        this.session?.destroy()
        BackgroundTask.getInstance().stopBackgroundTask()
        this.player
            .removeOnPreparedListener(this.prepareListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnCompletionListener(this.completedListener)
            .release()
    }
}
