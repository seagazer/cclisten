import common from '@ohos.app.ability.common'
import { DEFAULT_THEME, Theme } from './Theme'
import { DbHelper } from '../extensions/DbHelper'
import { APP_THEME, LiveData } from '../extensions/LiveData'


const TAG = "[ThemeManager]"


/**
 * The manager to manage a playlist of user.
 *
 * Author: seagazer
 * Date: 2023/11/1
 */
export class ThemeManager {
    private static sInstance: ThemeManager = null
    private db: DbHelper<Theme>

    private constructor() {
        this.db = new DbHelper<Theme>()
    }

    static get(): ThemeManager {
        if (!this.sInstance) {
            this.sInstance = new ThemeManager()
        }
        return this.sInstance
    }

    async init(context: common.Context) {
        this.db.addColumn("colorPrimary", "TEXT")
        this.db.addColumn("colorSecondary", "TEXT")
        this.db.addColumn("colorAction", "TEXT")
        await this.db.create(context, "appTheme")
    }

    async saveTheme(theme: Theme) {
        await this.db.insert(theme)
    }

    async readTheme() {
        let data = await this.db.query()
        if (data.length > 0) {
            return data[0]
        }
        return DEFAULT_THEME
    }

    updateTheme(theme: Theme) {
        LiveData.setValue(APP_THEME, theme)
    }
}