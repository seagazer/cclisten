/**
 * Author: seagazer
 * Date: 2023/11/19
 */
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';
import { Platform } from './Platform';

export class PreferenceHelper {
    private sp: preferences.Preferences | null = null

    constructor(context: common.Context, name: string) {
        if (Platform.apiVersion() > 9) {
            this.sp = preferences.getPreferencesSync(context, {
                name: name
            })
        } else {
            preferences.getPreferences(context, name, (err, sp) => {
                this.sp = sp
            })
        }
    }

    async write(key: string, value: preferences.ValueType) {
        this.sp?.put(key, value)
        await this.sp?.flush()
    }

    async read<T extends preferences.ValueType>(key: string, defaultValue: preferences.ValueType) {
        if (Platform.apiVersion() > 9) {
            return this.sp?.getSync(key, defaultValue) as T
        } else {
            return await this.sp?.get(key, defaultValue) as T
        }
    }
}
