@Entry
@Component
struct Index {
    private ctx = new CanvasRenderingContext2D()
    private w = 0
    private h = 0

    build() {
        Column() {
            Canvas(this.ctx)
                .width("100%")
                .height("100%")
                .padding({ left: 16, right: 16 })
                .onAppear(() => {
                    this.ctx.fillStyle = "#000000"
                    this.ctx.font = "64px"
                    //                    this.ctx.textAlign = "center"
                    this.ctx.fillText("娲皇宫爱何辜哇偶刚把我赶娲皇宫爱何辜哇偶刚把我赶", 0, 100)
                })
                .onAreaChange((_, newSize) => {
                    this.w = newSize.width as number
                    this.h = newSize.height as number
                })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
    }
}