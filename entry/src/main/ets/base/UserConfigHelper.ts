import common from '@ohos.app.ability.common'
import { PreferenceHelper } from './PreferenceHelper'
import preferences from '@ohos.data.preferences'

/**
 * Author: seagazer
 * Date: 2023/11/19
 */
export class UserConfigHelper {
    static CONFIG_INIT_STEP = "step"
    static CONFIG_THEME = "theme"
    private static sInstance: UserConfigHelper = null
    private sp: PreferenceHelper

    private constructor(context: common.Context) {
        this.sp = new PreferenceHelper(context, "AppUserConfig")
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

    async read<T extends preferences.ValueType>(key: string, defaultValue: preferences.ValueType) {
        return await this.sp.read<T>(key, defaultValue)
    }
}
