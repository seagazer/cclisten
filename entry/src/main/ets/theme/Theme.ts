/**
 * Author: seagazer
 * Date: 2023/4/9
 */
export class Theme {
    colorPrimary: string
    colorSecondary: string
    colorAction: string

    constructor(colorPrimary: string, colorSecondary: string, colorAction: string = "#80b7b7b7") {
        this.colorPrimary = colorPrimary
        this.colorSecondary = colorSecondary
        this.colorAction = colorAction
    }
}

export const DEFAULT_THEME = new Theme("#ff000000", "#e69a9a9a")

export const APP_THEME = "APP_THEME"