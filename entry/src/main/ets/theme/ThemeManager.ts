import { APP_THEME, LiveData } from '../extensions/LiveData'
import { Theme } from './Theme'

/**
 * Author: seagazer
 * Date: 2023/4/9
 */
export class ThemeManager {
    static updateTheme(theme: Theme) {
        LiveData.setValue(APP_THEME, theme)
    }
}