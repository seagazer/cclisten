import Animator, { AnimatorResult } from '@ohos.animator'

@Preview
@Component
export struct AnimCoverView {
    strokeColor: string = "#000000"
    strokeWidth: number = 4
    viewSize: number = 320
    @Watch("stateChanged") @Prop isAnim: boolean = false
    private anim: AnimatorResult = Animator.create({
        duration: 4 * 1000,
        easing: "linear",
        delay: 0,
        fill: "forwards",
        direction: 'normal',
        iterations: -1,
        begin: 0,
        end: 1
    })
    @State animAlpha: number = 0
    @State animSize: number = 0

    aboutToAppear() {
        this.anim.onframe = (progress) => {
            this.animSize = this.viewSize - 48 + 48 * progress
            this.animAlpha = 1 - progress
        }
    }

    build() {
        Stack() {
            Stack()
                .width(this.animSize)
                .height(this.animSize)
                .border({ radius: this.animSize })
                .opacity(this.animAlpha)
                .backgroundColor(this.strokeColor)

            Image($r('app.media.ic_cover'))
                .objectFit(ImageFit.Contain)
                .width(this.viewSize - 48)
                .height(this.viewSize - 48)
                .border({ radius: this.viewSize / 2, width: this.strokeWidth, color: this.strokeColor })
        }
        .width(this.viewSize)
        .height(this.viewSize)
    }

    stateChanged() {
        if (this.isAnim) {
            this.anim.play()
        } else {
            this.anim.cancel()
        }
    }

    aboutToDisappear() {
        this.anim.cancel()
    }
}