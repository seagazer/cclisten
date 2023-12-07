import common from '@ohos.app.ability.common'
import { Logger } from '../extensions/Logger'
import { History } from '../bean/History'
import { PreferenceHelper } from '../base/PreferenceHelper'

const TAG = "[PlayHistoryManager]"

/**
 * Author: seagazer
 * Date: 2023/12/5
 */
export class PlayHistoryManager {
    private static sInstance: PlayHistoryManager = null
    private sp: PreferenceHelper
    private fileName = "history"
    private key = "data"

    private constructor(context: common.Context) {
        this.sp = new PreferenceHelper(context, "PlayHistory")
    }

    public static get(context: common.Context): PlayHistoryManager {
        if (this.sInstance == null) {
            this.sInstance = new PlayHistoryManager(context)
        }
        return this.sInstance
    }

    public async saveHistory(history: History) {
        try {
            Logger.d(TAG, "save history")
            if (history) {
                this.sp.write(this.key, JSON.stringify(history))
                Logger.d(TAG, "save history success= " + JSON.stringify(history))
            } else {
                Logger.e(TAG, "save history error, the song is null!")
            }
        } catch (err) {
            Logger.e(TAG, "save history error= " + JSON.parse(err))
        }
    }

    public async readHistory() {
        try {
            Logger.d(TAG, "read history")
            let data = await this.sp.read<string>(this.key, "")
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