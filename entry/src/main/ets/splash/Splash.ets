import router from '@ohos.router'

class LogoText {
    text: string
    offsetX: number
    offsetY: number

    constructor(text: string, offsetX: number, offsetY: number) {
        this.text = text
        this.offsetX = offsetX
        this.offsetY = offsetY
    }
}


@Entry
@Component
struct Index {
    private themeColor = '#ff000000'
    private logoName: Array<string> = ["L", "i", "s", "t", "e", "n"]
    @State logo: Array<LogoText> = []

    aboutToAppear() {
        for (let i = 0;i < this.logoName.length; i++) {
            let y = Math.random() * 100
            let rand = ~~(Math.random() * 10) % 2 == 0
            if (rand) {
                y = -y
            }
            let item = new LogoText(this.logoName[i], 0, 0)
            this.logo.push(item)
        }

        setTimeout(() => {
            router.pushUrl({
                url: "home/Home"
            })
        }, 2000)
    }

    build() {
        Row() {
            ForEach(this.logo, (title: LogoText, index) => {
                Text(title.text)
                    .fontColor(this.themeColor)
                    .fontSize(40)
                    .translate({ y: title.offsetY })
                    .margin(title.offsetX)
            })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
    }

    pageTransition() {
        PageTransitionExit({ duration: 600 }).scale({ x: 0, y: 0 }).opacity(0)
    }
}