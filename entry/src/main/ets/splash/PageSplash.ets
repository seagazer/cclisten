import { Logger } from '@seagazer/ccplayer'
import { Song } from '../bean/Song'
import { navigationTo } from '../extensions/Extensions'
import {
    APP_THEME,
    MEDIA_SESSION_CURRENT_SONG,
    MEDIA_SESSION_FILE_LIST,
    MEDIA_SESSION_PLAYING_STATE,
    MEDIA_SESSION_POSITION,
} from '../extensions/LiveData'
import { PageRouter } from '../extensions/PageRouter'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { ThemeManager } from '../theme/ThemeManager'

PersistentStorage.PersistProp<string>("themeString", JSON.stringify(DEFAULT_THEME))
PersistentStorage.PersistProp<string>("isAppInit", "0")
const TAG = "PageSplash"

@Entry
@Component
struct PageSplash {
    // init all the livedata >>
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_CURRENT_SONG) currentSong: Song = null
    @StorageLink(MEDIA_SESSION_PLAYING_STATE) isPlaying: boolean = false
    @StorageLink(MEDIA_SESSION_POSITION) currentPosition: number = 0
    @StorageLink(MEDIA_SESSION_FILE_LIST) fileList: Array<Song> = null
    // init all the livedata <<

    private logoName = ["L", "i", "s", "t", "e", "n"]
    @State alphas: Array<number> = new Array()
    private duration = 600
    private delay = 200
    @StorageLink("isAppInit") isAppInit: string = "0"
    @StorageLink("themeString") themeString: string = JSON.stringify(DEFAULT_THEME)

    // {"id":0,"width":720,"height":1280,"refreshRate":69,"name":"display_0","alive":true,"state":0,"rotation":0,
    // "densityDPI":240,"densityPixels":1.5,"scaledDensity":1.5,"xDPI":0,"yDPI":0}
    aboutToAppear() {
        Logger.d(TAG, "isAppInit = " + this.isAppInit)
        if (this.isAppInit === "1") {
            let theme = JSON.parse(this.themeString)
            ThemeManager.updateTheme(theme)
        } else {
            ThemeManager.updateTheme(new Theme("#FF405C", "#ffea223f"))
        }
        this.logoName.forEach((_, index) => {
            this.alphas[index] = 0
        })
    }

    build() {
        Row() {
            ForEach(this.logoName, (name, index) => {
                Text(name)
                    .fontSize(48)
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
                if (this.isAppInit === "0") {
                    navigationTo(PageRouter.PAGE_GUIDE_WELCOME)
                } else {
                    navigationTo(PageRouter.PAGE_GUIDE_BROWSE)
                }
            }, 500 + this.duration + this.delay * this.logoName.length)
        })
    }

    pageTransition() {
        PageTransitionExit({ duration: 500 }).opacity(0)
    }
}