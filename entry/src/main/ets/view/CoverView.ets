@Component
export struct CoverView {
    private src: Resource
    private themeColor: ResourceColor
    @State angle: number = 0
    @Watch("onPlayStateChanged") @Link isPlaying: boolean

    private onPlayStateChanged() {
        if (this.isPlaying) {
            this.angle = 360
        } else {
            this.angle = this.angle
        }
    }

    build() {
        Image(this.src)
            .width(240)
            .aspectRatio(1)
            .rotate({ angle: this.angle })
            .border({
                radius: '200',
                color: this.themeColor,
                width: 8
            })
            .margin({ top: 64, bottom: 64 })
            .animation({
                duration: 120 * 1000,
                playMode: PlayMode.Reverse,
                iterations: -1,
                curve: Curve.Linear
            })
    }
}