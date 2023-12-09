import { Logger } from '@seagazer/ccplayer'
import { UIConfig } from '../config/UIConfig'
import { navigationTo } from '../extensions/Extensions'
import { APP_THEME } from '../extensions/LiveData'
import { PageRouter } from '../extensions/PageRouter'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { ThemeManager } from '../theme/ThemeManager'
import { UserConfigHelper } from '../config/UserConfigHelper'
import { PlayHistoryManager } from '../history/PlayHistoryManager'
import { History } from '../bean/History'

const TAG = "[PageSplash]"

@Entry
@Component
struct PageSplash {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    private logoName = ["L", "i", "s", "t", "e", "n"]
    @State alphas: Array<number> = new Array()
    private duration = 500
    private delay = 200
    private isAppInit: number = 0
    private history?: History | null = null

    // {"id":0,"width":720,"height":1280,"refreshRate":69,"name":"display_0","alive":true,"state":0,"rotation":0,
    // "densityDPI":240,"densityPixels":1.5,"scaledDensity":1.5,"xDPI":0,"yDPI":0}
    aboutToAppear() {
        this.init()
    }

    private async init() {
        let sp = UserConfigHelper.get(getContext(this))
        this.isAppInit = await sp.read<number>(UserConfigHelper.CONFIG_INIT_STEP, 0)
        Logger.d(TAG, "isAppInit = " + this.isAppInit)
        // init playlist when playing animation
        if (this.isAppInit > 0) {
            this.loadTheme()
        } else {
            ThemeManager.get().updateTheme(new Theme("#FF405C", "#ffea223f"))
        }
        this.logoName.forEach((_, index) => {
            this.alphas[index] = 0
        })
        this.history = await PlayHistoryManager.get().readHistory()
    }

    private async loadTheme() {
        let theme = await ThemeManager.get().readTheme()
        Logger.d(TAG, "user theme =" + JSON.stringify(theme))
        ThemeManager.get().updateTheme(theme)
    }

    build() {
        Row() {
            ForEach(this.logoName, (name: string, index) => {
                Text(name)
                    .fontSize(UIConfig.FONT_LOGO)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.theme.colorPrimary)
                    .scale({ x: this.alphas[index], y: this.alphas[index] })
                    .opacity(this.alphas[index])
            })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
        .onAreaChange(() => {
            this.logoName.forEach((_, index) => {
                animateTo(
                    {
                        duration: this.duration,
                        delay: this.delay * index,
                        curve: Curve.Friction
                    },
                    () => {
                        this.alphas[index] = 1
                    })
            })
            setTimeout(() => {
                if (this.isAppInit == 0) {
                    navigationTo(PageRouter.PAGE_SETUPWIZARD_WELCOME)
                } else if (this.isAppInit == 1) {
                    navigationTo(PageRouter.PAGE_SETUPWIZARD_MEDIA_LIBRARY)
                } else {
                    Logger.d(TAG, "read history = " + JSON.stringify(this.history))
                    navigationTo(PageRouter.PAGE_HOME, { history: this.history })
                }
            }, 500 + this.duration + this.delay * this.logoName.length)
        })
    }

    pageTransition() {
        PageTransitionExit({ duration: 500 }).opacity(0)
    }
}