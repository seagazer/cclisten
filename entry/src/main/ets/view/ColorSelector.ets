@Preview
@Component
export struct ColorSelector {
    private settings: RenderingContextSettings = new RenderingContextSettings(true)
    private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
    @State selectedColor: string = ""

    private drawCircle() {
        let grad2 = this.ctx.createRadialGradient(150, 150, 1, 150, 150, 150)
        grad2.addColorStop(0.0, '#ffe3e3e3')
        grad2.addColorStop(0.5, '#80ffffff')
        grad2.addColorStop(1.0, '#00ffffff')
        this.ctx.fillStyle = grad2
        this.ctx.beginPath()
        this.ctx.arc(150, 150, 150, 0, this.angleToRadian(360))
        this.ctx.fill()
    }

    private angleToRadian(angle: number): number {
        return angle / (180 / Math.PI)
    }

    build() {
        Column() {
            Canvas(this.ctx)
                .width(300)
                .height(300)
                .border({ radius: 150 })
                .onReady(() => {
                    this.ctx.strokeStyle = "#000000"
                    this.ctx.lineWidth = 2
                    this.drawCircle()
                })
                .onTouch((ev) => {
                    let touch = ev.touches[0]
                    switch (touch.type) {
                        case TouchType.Down:
                        case TouchType.Move:
                            this.ctx.clearRect(0, 0, this.ctx.width, this.ctx.height)
                            this.drawCircle()
                            this.ctx.beginPath()
                            let x = touch.x
                            let y = touch.y
                            this.ctx.arc(x, y, 8, 0, this.angleToRadian(360))
                            this.ctx.stroke()
                            let dr = Math.sqrt((x - 150) * (x - 150) + (y - 150) * (y - 150))

                            let hsv = new Array<number>()
                            hsv[0] = Math.atan2((y - 150), -(x - 150)) / Math.PI * 180 + 180
                            hsv[1] = Math.max(0, Math.min(1, dr / 150))
                            hsv[2] = 1
                            this.selectedColor = this.hsv2rgb(hsv[0], hsv[1], hsv[2])
                            console.warn("aaa-" + this.selectedColor + ", " + JSON.stringify(hsv))
                            break
                    }
                })
                .sweepGradient({
                    center: [150, 150],
                    start: 0,
                    end: 360,
                    rotation: 0,
                    repeating: true,
                    colors: [[0xff0000, 0.0], [0xFC27D9, 0.166], [0x0000ff, 0.332],
                        [0x0AE4E3, 0.5], [0x00ff00, 0.664], [0xffff00, 0.831], [0xff0000, 1]]
                })

            Row()
                .width(100)
                .height(100)
                .border({ radius: 50 })
                .margin({ top: 16 })
                .backgroundColor(this.selectedColor)
        }
    }

    private hsv2rgb(h: number, s: number, v: number) {
        let i: number, f: number, p1: number, p2: number, p3: number
        let r = 0, g = 0, b = 0
        if (s < 0) s = 0
        if (s > 1) s = 1
        if (v < 0) v = 0
        if (v > 1) v = 1
        h %= 360
        if (h < 0) h += 360
        h /= 60
        i = Math.floor(h)
        f = h - i
        p1 = v * (1 - s)
        p2 = v * (1 - s * f)
        p3 = v * (1 - s * (1 - f))
        switch (i) {
            case 0:
                r = v
                g = p3
                b = p1
                break
            case 1:
                r = p2
                g = v
                b = p1
                break
            case 2:
                r = p1
                g = v
                b = p3
                break
            case 3:
                r = p1
                g = p2
                b = v
                break
            case 4:
                r = p3
                g = p1
                b = v
                break
            case 5:
                r = v
                g = p1
                b = p2
                break
        }
        let r1 = Math.round(r * 255)
        let g1 = Math.round(g * 255)
        let b1 = Math.round(b * 255)
        return "#" + ((1 << 24) + (r1 << 16) + (g1 << 8) + b1).toString(16).slice(1)
    }
}