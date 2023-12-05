import common from '@ohos.app.ability.common'
import { DEFAULT_THEME, Theme } from './Theme'
import { DbHelper } from '../base/DbHelper'
import { APP_THEME, LiveData } from '../extensions/LiveData'
import { UserConfigHelper } from '../base/UserConfigHelper'


const TAG = "[ThemeManager]"


/**
 * The manager to manage a playlist of user.
 *
 * Author: seagazer
 * Date: 2023/11/1
 */
export class ThemeManager {
    private static sInstance: ThemeManager = null
    private sp: UserConfigHelper

    private constructor() {
    }

    static get(): ThemeManager {
        if (!this.sInstance) {
            this.sInstance = new ThemeManager()
        }
        return this.sInstance
    }

    async init(context: common.Context) {
        this.sp = UserConfigHelper.get(context)
    }

    async saveTheme(theme: Theme) {
        this.sp?.write(UserConfigHelper.CONFIG_THEME, JSON.stringify(theme))
    }

    async readTheme() {
        let data = await this.sp.read<string>(UserConfigHelper.CONFIG_THEME, "")
        if (data.length > 0) {
            return JSON.parse(data) as Theme
        }
        return DEFAULT_THEME
    }

    updateTheme(theme: Theme) {
        LiveData.setValue(APP_THEME, theme)
    }
}