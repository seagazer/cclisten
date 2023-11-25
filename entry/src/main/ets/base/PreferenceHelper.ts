/**
 * Author: seagazer
 * Date: 2023/11/19
 */
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';

export class Preference {
    private sp: preferences.Preferences | null = null

    constructor(context: common.Context, name: string) {
        this.sp = preferences.getPreferencesSync(context, {
            name: name
        })
    }

    async write(key: string, value: preferences.ValueType) {
        this.sp?.put(key, value)
        await this.sp?.flush()
    }

    read<T extends preferences.ValueType>(key: string, defaultValue: preferences.ValueType) {
        return this.sp?.getSync(key, defaultValue) as T
    }
}
