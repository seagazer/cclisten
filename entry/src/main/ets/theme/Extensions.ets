import { Theme } from './Theme'

export function setTheme(theme: Theme) {
    AppStorage.Set<Theme>("theme", theme)
}