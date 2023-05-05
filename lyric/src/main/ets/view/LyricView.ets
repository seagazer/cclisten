import { LyricWrapper } from '../bean/LyricWrapper';
import { printD, printW } from '../extensions/Extension';
import { Lyric } from '../bean/Lyric';
import animator, { AnimatorResult } from '@ohos.animator';

// default config
const DEFAULT_LINE_SPACE = 16
const DEFAULT_TEXT_SIZE = 48
const DEFAULT_HIGHLIGHT_SCALE = 1.15
const DEFAULT_TEXT_COLOR = "#ff929292"
const DEFAULT_HIGHLIGHT_COLOR = "#000000"
const DEFAULT_EDGE_COLOR = "#ffffff"
const DEFAULT_ANIM_DURATION = 500

@Component
export struct LyricView {
    /*------------------------------setter----------------------------------*/
    private lrcList: Array<Lyric> = new Array<Lyric>()
    private textColor: string = DEFAULT_TEXT_COLOR
    private textSize: number = DEFAULT_TEXT_SIZE
    private highLightColor: string = DEFAULT_HIGHLIGHT_COLOR
    private highLightScale: number = DEFAULT_HIGHLIGHT_SCALE
    private edgeColor: string = DEFAULT_EDGE_COLOR
    private lineSpace: number = DEFAULT_LINE_SPACE
    private animDuration: number = DEFAULT_ANIM_DURATION
    @Watch("onProgressChanged") @Link duration: number
    @Watch("onIndexChanged") @Link targetIndex: number
    /*----------------------------------------------------------------------*/
    readonly extLrcList = new Array<LyricWrapper>()
    readonly settings = new RenderingContextSettings(true)
    readonly canvasCtx = new CanvasRenderingContext2D(this.settings)
    private highLightTextSize = DEFAULT_TEXT_SIZE
    private highLightDrawOffset = 0
    private w = 0
    private h = 0
    private centerH = 0
    private centerW = 0
    private scrollY = 0
    private linearGradientEdge = 150 // the size of linear gradient at top and bottom.
    private targetScrollY = 0 // the target end scrollY of the animation.
    private centerYOffset = 0 // the center y of the lyric view.
    private currentIndex = 0
    private firstVisibleIndex = 0 // the first visible item index at top.
    private lastVisibleIndex = 0 // the last visible item index at bottom.
    private topOverOffIndex = -1 // the index of highlight item when has one more item out off the top.
    private anim: AnimatorResult
    private isAnimRunning = false

    aboutToAppear() {
        this.highLightTextSize = this.textSize * this.highLightScale
        this.highLightDrawOffset = this.textSize * (this.highLightScale - 1) / 2
        this.anim = animator.create({
            duration: this.animDuration,
            easing: "ease-in-out",
            delay: 0,
            fill: "forwards",
            direction: "normal",
            iterations: 1,
            begin: this.scrollY,
            end: this.targetScrollY
        })
        this.anim.oncancel = () => {
            this.isAnimRunning = false
        }
        this.anim.onfinish = () => {
            this.isAnimRunning = false
        }
    }

    build() {
        Canvas(this.canvasCtx)
            .onAppear(() => {
                printD("-----------------on appear")
                // init paint
                this.initPaint()
                // TODO preview call initSize here, the onAppear is later than onAreaChanged
                this.initSize()
            })
            .onAreaChange((_, newSize) => {
                printD("-----------------on size changed")
                this.w = newSize.width as number
                this.h = newSize.height as number
                printD("canvas size=" + this.w + " * " + this.h)
                this.centerW = this.w / 2
                this.centerH = this.h / 2
                // init size
                // TODO real device call initSize here, the onAreaChanged is later than onAppear
                // this.initSize()
            })
    }

    private initPaint() {
        this.canvasCtx.fillStyle = this.textColor
        this.canvasCtx.strokeStyle = this.textColor
        this.canvasCtx.lineWidth = 1
        this.canvasCtx.font = this.textSize + "px"
        // TODO: the center textAlign has bugs when multi line in OpenHarmony 3.2
        // this.canvasCtx.textAlign = "center"
    }

    private initSize() {
        this.scrollY = this.h / 2 // layout center when first display
        let tempH = 0
        for (let i = 0;i < this.lrcList.length; i++) {
            let lrc = this.lrcList[i]
            let textMeasure = this.canvasCtx.measureText(lrc.text)
            let lp = textMeasure.width / this.w
            let lines = 1
            if (textMeasure.width % this.w != 0) {
                lines = lp < 1 ? 1 : Math.round(lp) + 1
            } else {
                lines = lp
            }
            let lineHeight = lines > 1 ? lines * textMeasure.height : textMeasure.height
            if (i == 0) {
                tempH = Math.floor(textMeasure.height / 2)
                this.centerYOffset = tempH
            }
            if (tempH < this.h / 2) {
                tempH += lineHeight + this.lineSpace
            } else {
                if (this.topOverOffIndex == -1) {
                    this.topOverOffIndex = i - 1 // if current index is topOverOffIndex, top off screen
                    printW("over top index=" + this.topOverOffIndex)
                }
            }
            this.extLrcList.push(new LyricWrapper(lrc, lineHeight))
        }
        this.firstVisibleIndex = this.getFirstVisibleIndex(this.currentIndex)
        this.lastVisibleIndex = this.getLastVisibleIndex(this.currentIndex)
        this.invalidate()
    }

    private invalidate() {
        // clear canvas
        this.canvasCtx.clearRect(0, 0, this.w, this.h)
        // draw center line
        //        this.drawCenterLine()
        // draw lrc text
        this.drawLrc()
        this.drawEdge()
    }

    private drawCenterLine() {
        this.canvasCtx.beginPath()
        this.canvasCtx.moveTo(0, this.centerH)
        this.canvasCtx.lineTo(this.w, this.centerH)
        this.canvasCtx.stroke()
    }

    private drawLrc() {
        let startY = this.centerYOffset // half of the first line measure text height
        this.canvasCtx.save()
        this.canvasCtx.translate(0, this.scrollY)
        // the draw count is the max visible lines in screen + 4 caches(2 top & 2 bottom)
        for (let i = 0;i < this.extLrcList.length; i++) {
            let lrc = this.extLrcList[i]
            // out the top of screen, the cache is 2 lines
            if (i < this.firstVisibleIndex - 2) {
                startY += (lrc.height + this.lineSpace)
                continue
            }
            // out the bottom of screen, the cache is 2 lines
            if (i > this.lastVisibleIndex + 2) {
                break
            }
            // draw with high light for current line
            if (i == this.currentIndex) {
                let scaleHeight = this.drawHighLight(lrc, startY)
                startY += (scaleHeight + this.lineSpace)
            } else {
                this.canvasCtx.fillText(lrc.text, 0, startY)
                startY += (lrc.height + this.lineSpace)
            }
        }
        this.canvasCtx.restore()
    }

    private drawHighLight(lrc: LyricWrapper, startY: number): number {
        this.canvasCtx.save()
        this.canvasCtx.font = this.highLightTextSize + "px"
        this.canvasCtx.fillStyle = this.highLightColor
        this.canvasCtx.fillText(lrc.text, 0, startY + this.highLightDrawOffset)
        let textMeasure = this.canvasCtx.measureText(lrc.text)
        let height = Math.floor(textMeasure.height)
        let width = textMeasure.width
        let lp = textMeasure.width / this.w
        let lines = 1
        if (textMeasure.width % this.w != 0) {
            lines = lp < 1 ? 1 : Math.round(lp) + 1
        } else {
            lines = lp
        }
        let scaleHeight = height * lines
        this.canvasCtx.restore()
        return scaleHeight
    }

    private drawEdge() {
        this.canvasCtx.save()
        let grad1 = this.canvasCtx.createLinearGradient(this.centerW, 0, this.centerW, this.linearGradientEdge)
        grad1.addColorStop(0.0, this.edgeColor)
        grad1.addColorStop(1.0, '#00ffffff')
        this.canvasCtx.fillStyle = grad1
        this.canvasCtx.fillRect(0, 0, this.w, this.linearGradientEdge)
        let grad2 = this.canvasCtx.createLinearGradient(this.centerW, this.h, this.centerW, this.h - this.linearGradientEdge)
        grad2.addColorStop(0.0, this.edgeColor)
        grad2.addColorStop(1.0, '#00ffffff')
        this.canvasCtx.fillStyle = grad2
        this.canvasCtx.fillRect(0, this.h - this.linearGradientEdge, this.w, this.linearGradientEdge)
        this.canvasCtx.restore()
    }

    private getIndex(position: number): number {
        let first = this.extLrcList[0].timestamp
        if (position < first) {
            return 0
        }
        let last = this.extLrcList[this.extLrcList.length-1].timestamp
        if (position > last) {
            return this.extLrcList.length - 1
        }
        for (let i = 0;i < this.extLrcList.length; i++) {
            let l1 = this.extLrcList[i].timestamp
            let l2 = this.extLrcList[i+1].timestamp
            if (position > l1 && position < l2) {
                return i
            }
        }
        return this.currentIndex
    }

    private getFirstVisibleIndex(index: number): number {
        if (index > this.topOverOffIndex) {
            let tempH = 0
            for (let i = index;i > 0; i--) {
                let lrc = this.extLrcList[i]
                tempH += (lrc.height + this.lineSpace)
                if (tempH > this.centerH) {
                    return i
                }
            }
        } else {
            return 0
        }
    }

    private getLastVisibleIndex(index: number): number {
        let tempH = 0
        for (let i = index;i < this.extLrcList.length; i++) {
            let lrc = this.extLrcList[i]
            tempH += (lrc.height + this.lineSpace)
            if (tempH > this.centerH) {
                return i
            }
        }
        return this.extLrcList.length - 1
    }

    private animateToIndex(index: number) {
        printW("animate to index=" + index)
        if (index == this.currentIndex) {
            printW("index not changed, not animate!")
            return
        }
        // out of range, return
        if (index > this.extLrcList.length - 1 || index < 0) {
            printW("out of range, not animate!")
            return
        }
        this.firstVisibleIndex = this.getFirstVisibleIndex(index)
        this.lastVisibleIndex = this.getLastVisibleIndex(index)
        let animOffset = 0
        let isUp = index > this.currentIndex
        if (isUp) { // to next
            for (let i = this.currentIndex;i < index; i++) {
                let lrcH = this.extLrcList[i].height
                animOffset += lrcH + this.lineSpace
            }
        } else { // to pre
            for (let i = index;i < this.currentIndex; i++) {
                let lrcH = this.extLrcList[i].height
                animOffset += lrcH + this.lineSpace
            }
        }
        this.currentIndex = index
        printD("firstTop=" + this.firstVisibleIndex + ", lastBottom=" + this.lastVisibleIndex + ", currentHighLight=" + this.currentIndex)
        // the animation is running, end it
        if (this.isAnimRunning) {
            this.anim.cancel()
            this.scrollY = this.targetScrollY
            this.invalidate()
            printW("intercept and end anim!")
        }
        // at end, stop scroll
        if (this.currentIndex > this.extLrcList.length - 1) {
            return
        }
        printD("-->start anim")
        // get the offset of one frame
        this.targetScrollY = Math.floor(isUp ? this.scrollY - animOffset : this.scrollY + animOffset)
        // start animate
        let startY = this.scrollY
        printD("-->start anim " + startY + " -> " + this.targetScrollY)
        this.anim.reset({
            duration: this.animDuration,
            easing: "ease-in-out",
            delay: 0,
            fill: "forwards",
            direction: "normal",
            iterations: 1,
            begin: startY,
            end: this.targetScrollY
        })
        this.anim.onframe = (value) => {
            this.scrollY = value
            this.invalidate()
        }
        this.anim.play()
        this.isAnimRunning = true
    }

    private onIndexChanged() {
        this.animateToIndex(this.targetIndex)
    }

    private onProgressChanged() {
        let index = this.getIndex(this.duration)
        if (index != this.currentIndex) {
            printD("go to next line=" + index)
            this.animateToIndex(index)
        }
    }
}