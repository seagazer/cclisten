import Animator, { AnimatorResult } from '@ohos.animator'
import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { UIConfig } from '../config/UIConfig'

@Component
export struct AnimCoverView {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    strokeWidth: number = 2
    viewSize: number = 320
    animEdge = 48
    animDuration = 5000
    @Watch("stateChanged") @Prop isAnim: boolean = false
    private anim?: AnimatorResult
    @State animAlpha: number = 0
    @State animSize: number = 0
    private anim2?: AnimatorResult
    @State animAlpha2: number = 0
    @State animSize2: number = 0

    aboutToAppear() {
        this.anim = Animator.create({
            duration: this.animDuration,
            easing: "linear",
            delay: 0,
            fill: "forwards",
            direction: 'normal',
            iterations: -1,
            begin: 0,
            end: 1
        })
        this.anim2 = Animator.create({
            duration: this.animDuration,
            easing: "linear",
            delay: this.animDuration / 2,
            fill: "forwards",
            direction: 'normal',
            iterations: -1,
            begin: 0,
            end: 1
        })
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
                .backgroundColor(this.theme.colorPrimary)
            Stack()
                .width(this.animSize2)
                .height(this.animSize2)
                .border({ radius: this.animSize2 })
                .opacity(this.animAlpha2)
                .backgroundColor(this.theme.colorPrimary)
            Image($r('app.media.ic_cover'))
                .objectFit(ImageFit.Contain)
                .width(this.viewSize - this.animEdge)
                .height(this.viewSize - this.animEdge)
                .border({ radius: this.viewSize / 2 })
                .shadow({ radius: 18, color: this.theme.colorPrimary })
        }
        .width(this.viewSize)
        .height(this.viewSize)
        .scale({ x: this.isAnim ? 1 : 0.95, y: this.isAnim ? 1 : 0.95 })
        .animation({ duration: UIConfig.ANIM_DURATION })
    }

    stateChanged() {
        if (this.isAnim) {
            this.anim?.play()
            this.anim2?.play()
        } else {
            this.anim?.pause()
            this.anim2?.pause()
        }
    }

    aboutToDisappear() {
        this.anim?.cancel()
        this.anim2?.cancel()
    }
}