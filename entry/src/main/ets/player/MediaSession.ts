import { CcPlayer, PlayerType } from '@seagazer/ccplayer'
import { Logger } from '../extensions/Logger'
import { LoopMode } from './LoopMode'

const TAG = "MediaSession"

/**
 * Author: seagazer
 * Date: 2023/6/17
 */
export class MediaSession {
    private static sInstance: MediaSession = null
    private player: CcPlayer = null
    private isSeeking = false
    private loopMode: LoopMode = LoopMode.PLAYLIST_LOOP

    private constructor() {
        this.player = CcPlayer.create(PlayerType.AUDIO)
        this.player
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnPreparedListener(this.prepareListener)
            .addOnCompletionListener(this.completedListener)
            .addOnSeekChangedListener(() => {
                this.isSeeking = false
                Logger.d(TAG, "---seek completed")
            })
    }

    public static get(): MediaSession {
        if (this.sInstance == null) {
            this.sInstance = new MediaSession()
        }
        return this.sInstance
    }

    private progressChangedListener = (duration: number) => {
        if (!this.isSeeking) {
        }
    }
    private prepareListener = () => {
        this.isSeeking = false
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

    release() {
        this.player
            .removeOnPreparedListener(this.prepareListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnCompletionListener(this.completedListener)
            .release()
    }
}