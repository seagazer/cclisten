import { syncLiveData } from '../extensions/LiveData'
import { APP_THEME, Theme } from './Theme'

/**
 * Author: seagazer
 * Date: 2023/4/9
 */
export class ThemeManager {
    static updateTheme(theme: Theme) {
        syncLiveData(APP_THEME, theme)
    }
}