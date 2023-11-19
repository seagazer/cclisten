import common from '@ohos.app.ability.common'
import { Preference } from './Preference'
import { Context } from '@ohos.abilityAccessCtrl'
import preferences from '@ohos.data.preferences'

/**
 * Author: seagazer
 * Date: 2023/11/19
 */
export class UserConfigHelper {
    static CONFIG_INIT_STEP = "step"
    static CONFIG_THEME = "theme"
    private static sInstance: UserConfigHelper = null
    private sp: Preference

    constructor(context: Context) {
        this.sp = new Preference(context, "AppUserConfig")
    }

    public static get(context: common.Context) {
        if (!this.sInstance) {
            this.sInstance = new UserConfigHelper(context)
        }
        return this.sInstance
    }

    async write(key: string, value: preferences.ValueType) {
        await this.sp.write(key, value)
    }

    read<T extends preferences.ValueType>(key: string, defaultValue: preferences.ValueType) {
        return this.sp.read<T>(key, defaultValue)
    }
}
