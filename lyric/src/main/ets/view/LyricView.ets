import { printD, printW } from '../extensions/Extension';
import { Lyric } from '../bean/Lyric';

class LyricWrapper extends Lyric {
    readonly height: number

    constructor(src: Lyric, height: number) {
        super(src.timestamp, src.text)
        this.height = height
    }
}

@Component
export struct LyricView {
    /*------------------------------setter----------------------------------*/
    private lrcList = new Array<Lyric>()
    private textColor = "#ff929292"
    private textSize = 56
    private highLightColor = "#000000"
    private highLightScale = 1.2
    private edgeColor = "#ffffff"
    private lineSpace = vp2px(8)
    private animDuration = 800
    private frameRate = 30
    @Watch("onProgressChanged") @Link duration: number
    @Watch("onIndexChanged") @Link targetIndex: number
    /*----------------------------------------------------------------------*/
    readonly extLrcList = new Array<LyricWrapper>()
    readonly settings = new RenderingContextSettings(true)
    readonly canvasCtx = new CanvasRenderingContext2D(this.settings)
    private highLightTextSize = this.textSize * this.highLightScale
    private w = 0
    private h = 0
    private centerH = 0
    private centerW = 0
    private scrollY = 0
    private edge = 100
    private targetScrollY = 0
    private centerYOffset = 0
    private currentIndex = 0
    private firstVisibleIndex = 0
    private lastVisibleIndex = 0
    private topOverOffIndex = -1
    private animateTask = -1
    readonly frameCount = Math.floor(this.animDuration / 1000 * this.frameRate)
    readonly frameDuration = Math.floor(1000 / this.frameRate)

    build() {
        Canvas(this.canvasCtx)
            .onAppear(() => {
                printD("-----------------on appear")
                // init paint
                this.initPaint()
                // init size
                this.scrollY = this.h / 2 // layout center when first display
                let tempH = 0
                for (let i = 0;i < this.lrcList.length; i++) {
                    let lrc = this.lrcList[i]
                    let textMeasure = this.canvasCtx.measureText(lrc.text)
                    let lines = Math.floor(textMeasure.width / this.w + 1)
                    let lineHeight = lines > 1 ? lines * textMeasure.height : textMeasure.height
                    if (i == 0) {
                        tempH = Math.floor(textMeasure.height / 2)
                        this.centerYOffset = tempH
                    } else if (tempH < this.h / 2) {
                        tempH += lineHeight + this.lineSpace
                    } else if (this.topOverOffIndex == -1) {
                        this.topOverOffIndex = i - 1 // if current index is topOverOffIndex, top off screen
                        printW("over top index=" + this.topOverOffIndex)
                    }

                    this.extLrcList.push(new LyricWrapper(lrc, lineHeight))
                }
                this.firstVisibleIndex = this.getFirstVisibleIndex(this.currentIndex)
                this.lastVisibleIndex = this.getLastVisibleIndex(this.currentIndex)
                this.invalidate()
            })
            .onAreaChange((_, newSize) => {
                printD("-----------------on size changed")
                this.w = newSize.width as number
                this.h = newSize.height as number
                printD("canvas size=" + this.w + " * " + this.h)
                this.centerW = this.w / 2
                this.centerH = this.h / 2
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
        this.canvasCtx.fillText(lrc.text, 0, startY)
        let textMeasure = this.canvasCtx.measureText(lrc.text)
        let height = Math.floor(textMeasure.height)
        let width = textMeasure.width
        let lines = Math.floor(width / this.w + 1)
        printW("highLight: " + lrc.text + ", h=" + height + ", w=" + width + ", line=" + lines)
        let scaleHeight = height * lines
        this.canvasCtx.restore()
        return scaleHeight
    }

    private drawEdge() {
        this.canvasCtx.save()
        let grad1 = this.canvasCtx.createLinearGradient(this.centerW, 0, this.centerW, this.edge)
        grad1.addColorStop(0.0, this.edgeColor)
        grad1.addColorStop(1.0, '#00ffffff')
        this.canvasCtx.fillStyle = grad1
        this.canvasCtx.fillRect(0, 0, this.w, this.edge)
        let grad2 = this.canvasCtx.createLinearGradient(this.centerW, this.h, this.centerW, this.h - this.edge)
        grad2.addColorStop(0.0, this.edgeColor)
        grad2.addColorStop(1.0, '#00ffffff')
        this.canvasCtx.fillStyle = grad2
        this.canvasCtx.fillRect(0, this.h - this.edge, this.w, this.edge)
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
        if (this.animateTask != -1) {
            clearInterval(this.animateTask)
            this.scrollY = this.targetScrollY
            this.invalidate()
            printW("intercept and end anim!")
        }
        // get the offset of one frame
        this.targetScrollY = Math.floor(isUp ? this.scrollY - animOffset : this.scrollY + animOffset)
        let frameOffset = animOffset / this.frameCount
        // at end, stop scroll
        if (this.currentIndex > this.extLrcList.length - 1) {
            return
        }
        printD("-->start anim")
        // start animate
        let currentFrame = 0
        this.animateTask = setInterval(() => {
            currentFrame++
            if ((isUp && this.scrollY <= this.targetScrollY) || (!isUp && this.scrollY >= this.targetScrollY)) {
                clearInterval(this.animateTask)
                this.animateTask = -1
                if (this.scrollY != this.targetScrollY) {
                    printW("----------------resize")
                    this.scrollY = this.targetScrollY
                    this.invalidate()
                }
                printD("-->end anim")
            } else {
                // invalidate
                if (currentFrame >= this.frameCount) { // last frame
                    let end = isUp ? this.scrollY - frameOffset : this.scrollY + frameOffset
                    let overY = Math.abs(end - this.targetScrollY)
                    let dy = Math.floor(Math.abs(frameOffset - overY))
                    printD("end=" + end + ", overY=" + overY + ", frameCount=" + this.frameCount + ", lastFrame=" + currentFrame + ", dy=" + dy + ", totalOffset=" + animOffset + ", frameOffset=" + frameOffset)
                    this.scrollY = Math.floor(isUp ? this.scrollY - dy : this.scrollY + dy + 1)
                    printW("curY=" + this.scrollY + ", targetY=" + this.targetScrollY)
                } else {
                    printD("frameCount=" + this.frameCount + ", curFrame=" + currentFrame + ", totalOffset=" + animOffset + ", frameOffset=" + frameOffset)
                    this.scrollY = Math.floor(isUp ? this.scrollY - frameOffset : this.scrollY + frameOffset + 1)
                    printW("curY=" + this.scrollY + ", targetY=" + this.targetScrollY)
                }
                this.invalidate()
            }
        }, this.frameDuration)
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