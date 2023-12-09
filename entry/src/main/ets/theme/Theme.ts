/**
 * Author: seagazer
 * Date: 2023/4/9
 */
export class Theme {
    static APP_BACKGROUND_COLOR = "#ffffff"
    static APP_SYSTEM_COLOR = "#ff323232"
    colorPrimary: string
    colorAction: string

    constructor(colorPrimary: string, colorAction: string = "#80d4d4d4") {
        this.colorPrimary = colorPrimary
        this.colorAction = colorAction
    }
}

export const DEFAULT_THEME = new Theme("#ff000000", "#80d4d4d4")

export const THEME_COLOR = ["#FF405C", "#007DFF", "#47CC47", "#FF7500", "#E40078", "#00AAEE"]


