import { DEFAULT_THEME, Theme } from '../theme/Theme'
import router from '@ohos.router'
import { navigationTo } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'

@Entry
@Component
export struct PageWelcome {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    @State pageScale: number = 1
    @State pageAlpha: number = 1

    aboutToAppear() {
        router.clear()
    }

    build() {
        Column() {
            Text("欢迎使用Listen")
                .fontSize(48)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.theme.colorPrimary)

            Text("下面让我们开始吧")
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.theme.colorPrimary)
                .margin({ top: 16 })

            Button("好的")
                .type(ButtonType.Normal)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .shadow({ radius: 16, color: "#999c9c9c" })
                .fontSize(16)
                .margin({ top: 32 })
                .onClick(() => {
                    navigationTo(PageRouter.PAGE_GUIDE_SETUP)
                })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
        // .scale({ x: this.pageScale, y: this.pageScale })
        .opacity(this.pageAlpha)
    }

    pageTransition() {
        PageTransitionEnter({ duration: 600 }).onEnter((_: RouteType, progress: number) => {
            // this.pageScale = Math.min(1, progress + 0.5)
            this.pageAlpha = progress
        }).slide(SlideEffect.Bottom)
    }
}