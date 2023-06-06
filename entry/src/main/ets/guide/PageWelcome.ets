import { DEFAULT_THEME, Theme } from '../theme/Theme'

@Entry
@Component
export struct PageWelcome {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    @State pageScale: number = 1
    @State pageAlpha: number = 1

    build() {
        Column() {
            Text("欢 迎")
                .fontSize(48)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.theme.colorPrimary)

            Button("下一步")
                .fontSize(16)
                .margin({ top: 32 })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
        .scale({ x: this.pageScale, y: this.pageScale })
        .opacity(this.pageAlpha)
    }

    pageTransition() {
        PageTransitionEnter({ duration: 600 }).onEnter((_: RouteType, progress: number) => {
            this.pageScale = Math.min(1, progress + 0.5)
            this.pageAlpha = progress
        })
    }
}