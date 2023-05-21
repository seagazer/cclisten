import { DEFAULT_THEME, Theme } from '../theme/Theme'

@Component
export struct CoverView {
    src: Resource
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
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
                radius: 120,
                color: this.theme.colorPrimary,
                width: 6
            })
            .margin({ top: 64, bottom: 64 })
            .animation({
                duration: 120 * 1000,
                playMode: PlayMode.Normal,
                iterations: -1,
                curve: Curve.Linear
            })
    }
}