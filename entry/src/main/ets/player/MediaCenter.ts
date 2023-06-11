/**
 * The media center is a core module to manager all the play action of media player.
 */
import { CcPlayer, PlayerType } from '@seagazer/ccplayer'
import { Logger } from '../extensions/Logger'
import { LoopMode } from './LoopMode'

const TAG = "MediaCenter"

export class MediaCenter {
    private player: CcPlayer = null
    private curIndex = 0
    private isSeeking = false
    private loopMode: LoopMode = LoopMode.PLAYLIST_LOOP
    private currentPlayIndex = 0

    constructor() {
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

    private progressChangedListener = (duration: number) => {
        if (!this.isSeeking) {
        }
    }
    private prepareListener = () => {
        this.isSeeking = false
    }
    private completedListener = () => {
        switch (this.loopMode) {
            case LoopMode.PLAYLIST_LOOP:
                this.playNext()
                break
            case LoopMode.LOOP:
                this.player.start()
                break
            case LoopMode.SHUFFLE:
                // todo
                break
        }
    }

    setPlayMode(mode: LoopMode) {
        this.loopMode = mode
    }

    private playNext() {
        this.currentPlayIndex++
        if (this.currentPlayIndex > this.playlist.size() - 1) {
            this.currentPlayIndex = 0
        }
        let song = this.playlist.getSong(this.currentPlayIndex)
        Logger.d(TAG, "play next=" + this.currentPlayIndex + ", " + JSON.stringify(song))
        this.playSong(song)
    }

    private playPre() {
        this.currentPlayIndex--
        if (this.currentPlayIndex < 0) {
            this.currentPlayIndex = this.playlist.size() - 1
        }
        let song = this.playlist.getSong(this.currentPlayIndex)
        Logger.d(TAG, "play pre=" + this.currentPlayIndex + ", " + JSON.stringify(song))
        this.playSong(song)
    }

    private playSong(song: Song) {
        this.title = song.title
        this.artist = song.artist
        MediaSourceFactory.createAssets(getContext(this), song.url, song.title)
            .then((source) => {
                this.player.setMediaSource(source, () => {
                    this.player.start()
                })
            })
    }

    seekTo(value:number){
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