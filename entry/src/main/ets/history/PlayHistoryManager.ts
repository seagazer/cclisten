import common from '@ohos.app.ability.common'
import preferences from '@ohos.data.preferences'
import { Logger } from '../extensions/Logger'
import { History } from '../bean/History'

const TAG = "[PlayHistoryManager]"

/**
 * Author: seagazer
 * Date: 2023/8/27
 */
export class PlayHistoryManager {
    private static sInstance: PlayHistoryManager = null
    private fileName = "history"
    private key = "data"

    private constructor() {
    }

    public static get(): PlayHistoryManager {
        if (this.sInstance == null) {
            this.sInstance = new PlayHistoryManager()
        }
        return this.sInstance
    }

    public async saveHistory(context: common.Context, history: History) {
        try {
            Logger.d(TAG, "save history")
            if (history) {
                let sp = await preferences.getPreferences(context, this.fileName)
                await sp.put(this.key, JSON.stringify(history))
                await sp.flush()
                Logger.d(TAG, "save history success= " + JSON.stringify(history))
            } else {
                Logger.e(TAG, "save history error, the song is null!")
            }
        } catch (err) {
            Logger.e(TAG, "save history error= " + JSON.parse(err))
        }
    }

    public async readHistory(context: common.Context) {
        try {
            Logger.d(TAG, "read history")
            let sp = await preferences.getPreferences(context, this.fileName)
            let data = await sp.get(this.key, null)
            if (data) {
                Logger.d(TAG, "read history success= " + data)
                let history = JSON.parse(data.toString()) as History
                return history
            }
        } catch (err) {
            Logger.e(TAG, "read history error= " + JSON.parse(err))
            return null
        }
    }
}