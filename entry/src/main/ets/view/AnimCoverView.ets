import Animator, { AnimatorResult } from '@ohos.animator'

@Preview
@Component
export struct AnimCoverView {
    strokeColor: string = "#000000"
    strokeWidth: number = 2
    viewSize: number = 320
    animEdge = 48
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
    private anim2: AnimatorResult = Animator.create({
        duration: 4 * 1000,
        easing: "linear",
        delay: 2 * 1000,
        fill: "forwards",
        direction: 'normal',
        iterations: -1,
        begin: 0,
        end: 1
    })
    @State animAlpha2: number = 0
    @State animSize2: number = 0

    aboutToAppear() {
        this.anim.onframe = (progress) => {
            this.animSize = this.viewSize - this.animEdge + this.animEdge * progress
            this.animAlpha = 1 - progress
        }
        this.anim2.onframe = (progress) => {
            this.animSize2 = this.viewSize - this.animEdge + this.animEdge * progress
            this.animAlpha2 = 1 - progress
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
            Stack()
                .width(this.animSize2)
                .height(this.animSize2)
                .border({ radius: this.animSize2 })
                .opacity(this.animAlpha2)
                .backgroundColor(this.strokeColor)
            Image($r('app.media.ic_cover'))
                .objectFit(ImageFit.Contain)
                .width(this.viewSize - this.animEdge)
                .height(this.viewSize - this.animEdge)
                .border({ radius: this.viewSize / 2, width: this.strokeWidth, color: this.strokeColor })
        }
        .width(this.viewSize)
        .height(this.viewSize)
    }

    stateChanged() {
        if (this.isAnim) {
            this.anim.play()
            this.anim2.play()
        } else {
            this.anim.pause()
            this.anim2.pause()
        }
    }

    aboutToDisappear() {
        this.anim.cancel()
        this.anim2.cancel()
    }
}