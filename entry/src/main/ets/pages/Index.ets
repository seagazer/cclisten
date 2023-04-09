import { LyricView, Lyric, LyricParser } from '@seagazer/lyric';
import { MockData } from './MockData';

@Entry
@Component
struct Index {
    @State duration: number = 0
    private lrcList = new Array<Lyric>()

    aboutToAppear() {
        this.lrcList = new LyricParser().parse(MockData.src)
    }

    private test() {
        this.duration = 0
        let testTaskId = setInterval(() => {
            this.duration += 1000
            if (this.duration > this.lrcList[this.lrcList.length-1].timestamp + 1000) {
                clearInterval(testTaskId)
            }
        }, 1000)
    }

    @State testIndex: number = 0

    build() {
        Column() {
            LyricView({ lrcList: this.lrcList, duration: $duration, targetIndex: $testIndex })
                .width("100%")
                .height("60%")
            Row() {
                Button('Pre')
                    .onClick(() => {
                        let temp = this.testIndex - 1
                        if (temp < 0) {
                            temp = 0
                        }
                        this.testIndex = temp
                    })
                Button('Next')
                    .onClick(() => {
                        let temp = this.testIndex + 1
                        if (temp > this.lrcList.length - 1) {
                            temp = this.lrcList.length - 1
                        }
                        this.testIndex = temp
                    }).margin({ left: 16 })
                Button('Auto')
                    .onClick(() => {
                        this.test()
                    }).margin({ left: 16 })
            }
            .width("100%")
            .justifyContent(FlexAlign.Center)
            .margin({ top: 36 })

            Text(this.duration / 1000 + "s")
                .fontSize(24)
                .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
    }
}