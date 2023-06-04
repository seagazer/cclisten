import { Theme } from './Theme'


export class ThemeManager {
    static setTheme(theme: Theme) {
        AppStorage.Set<Theme>("theme", theme)
    }
}