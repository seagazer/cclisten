import common from '@ohos.app.ability.common'
import preferences from '@ohos.data.preferences'
import { Logger } from '../extensions/Logger'
import { LiveData, MEDIA_SESSION_CURRENT_SONG } from '../extensions/LiveData'
import { Song } from '../bean/Song'

const TAG = "[PlayHistoryManager]"

export class PlayHistoryManager {
    private static sInstance: PlayHistoryManager = null

    private constructor() {
    }

    public static get(): PlayHistoryManager {
        if (this.sInstance == null) {
            this.sInstance = new PlayHistoryManager()
        }
        return this.sInstance
    }

    public async saveHistory(context: common.Context, song: Song) {
        try {
            Logger.d(TAG, "save history")
            if (song) {
                let sp = await preferences.getPreferences(context, "history")
                await sp.put("data", JSON.stringify(song))
                await sp.flush()
                Logger.d(TAG, "save history success= " + JSON.stringify(song))
            } else {
                Logger.e(TAG, "save history error, the song is null!")
            }
        } catch (err) {
            Logger.e(TAG, "save history error= " + JSON.parse(err))
        }
    }

    public async initPlayHistory(context: common.Context) {
        try {
            Logger.d(TAG, "read history")
            let sp = await preferences.getPreferences(context, "history")
            let data = await sp.get("data", null)
            if (data) {
                Logger.d(TAG, "read history success= " + data)
                let song = JSON.parse(data.toString()) as Song
                LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, song)
                return song
            }
        } catch (err) {
            Logger.e(TAG, "read history error= " + JSON.parse(err))
            return null
        }
    }
}