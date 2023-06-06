import router from '@ohos.router'
import { navigationTo } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { ThemeManager } from '../theme/ThemeManager'


@Entry
@Component
struct PageSplash {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    private logoName = ["L", "i", "s", "t", "e", "n"]
    @State alphas: Array<number> = new Array()
    private duration = 600
    private delay = 200

    // {"id":0,"width":720,"height":1280,"refreshRate":69,"name":"display_0","alive":true,"state":0,"rotation":0,
    // "densityDPI":240,"densityPixels":1.5,"scaledDensity":1.5,"xDPI":0,"yDPI":0}
    aboutToAppear() {
        ThemeManager.setTheme(new Theme("#7D56C0", "#ff96aef8"))
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
                navigationTo(PageRouter.PAGE_GUIDE_WELCOME)
            }, 500 + this.duration + this.delay * this.logoName.length)
        })
    }

    pageTransition() {
        PageTransitionExit({ duration: 500 }).opacity(0)
    }
}