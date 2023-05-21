import router from '@ohos.router'
import { setTheme } from '../theme/Extensions'
import { DEFAULT_THEME, Theme } from '../theme/Theme'


@Entry
@Component
struct Index {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    private logoName = ["L", "i", "s", "t", "e", "n"]
    @State alphas: Array<number> = new Array()
    private duration = 800
    private delay = 200

    aboutToAppear() {
        setTheme(new Theme("#ff1b43b7", "#ff68d2ff"))
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
                router.pushUrl({
                    url: "home/Home"
                })
            }, 500 + this.duration + this.delay * this.logoName.length)
        })
    }

    pageTransition() {
        PageTransitionExit({ duration: 500 }).opacity(0)
    }
}