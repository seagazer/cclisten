import router from '@ohos.router'


@Extend(Text) function logoStyle() {
    .fontSize(48)
    .fontWeight(FontWeight.Medium)
}


@Entry
@Component
struct Index {
    private logoName = ["L", "i", "s", "t", "e", "n"]
    @State alphas: Array<number> = new Array()
    private duration = 800
    private delay = 200
    @State pageScale: number = 1
    @State pageAlpha: number = 1

    aboutToAppear() {
        this.logoName.forEach((_, index) => {
            this.alphas[index] = 0
        })
    }

    build() {
        Row() {
            ForEach(this.logoName, (name, index) => {
                Text(name)
                    .logoStyle()
                    .scale({ x: this.alphas[index], y: this.alphas[index] })
                    .opacity(this.alphas[index])
            })
        }
        .width("100%")
        .height("100%")
        .scale({ x: this.pageScale, y: this.pageScale })
        .opacity(this.pageAlpha)
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
        PageTransitionExit({ duration: 500 }).onExit((type: RouteType, progress: number) => {
            this.pageScale = 1 - progress
            this.pageAlpha = 1 - progress
        })
    }
}