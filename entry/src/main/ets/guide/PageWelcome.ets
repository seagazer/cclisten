import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { navigationTo } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'
import { Fab } from '../view/Fab'
import router from '@ohos.router'
import { APP_THEME } from '../extensions/LiveData'

@Entry
@Component
export struct PageWelcome {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @State translationValue: number = 1
    @State logoAnimValue: number = 0
    @State fabAnimValue: number = 0
    private themeColor: string

    aboutToAppear() {
        this.themeColor = this.theme.colorPrimary
        router.clear()
    }

    build() {
        Column() {
            Image($r("app.media.ic_welcome"))
                .width(100)
                .height(100)
                .scale({ x: this.logoAnimValue, y: this.logoAnimValue })
                .opacity(this.logoAnimValue)
                .animation({
                    duration: 600,
                    onFinish: () => {
                        setTimeout(() => {
                            this.fabAnimValue = 1
                        }, 1000)
                    }
                })

            Text("欢迎使用Listen")
                .fontSize(36)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.theme.colorPrimary)
                .margin({ top: 48 })
                .translate({ y: (1 - this.translationValue) * 100 })

            Text("下面让我们开始吧")
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.theme.colorPrimary)
                .margin({ top: 16 })
                .translate({ y: (1 - this.translationValue) * 50 })

            Fab({
                text: "好的",
                textSize: 18,
                color: this.themeColor,
                marginSize: { top: 56 },
                onAction: () => {
                    navigationTo(PageRouter.PAGE_GUIDE_SETUP)
                }
            }).opacity(this.fabAnimValue)
                .animation({
                    duration: 800,
                })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
        .opacity(this.translationValue)
        .onAreaChange(() => {

        })
    }

    pageTransition() {
        PageTransitionEnter({ duration: 800 }).onEnter((_: RouteType, progress: number) => {
            this.translationValue = progress
            if (progress >= 1) {
                this.logoAnimValue = 1
            }
        }).slide(SlideEffect.Bottom)
    }
}