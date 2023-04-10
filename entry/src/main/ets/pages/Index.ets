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
            LyricView({
                lrcList: this.lrcList,
                duration: $duration,
                targetIndex: $testIndex,
                textSize: 32,
                highLightScale: 1.2,
                lineSpace: 16,
                textColor: "#cccd7942",
                highLightColor: "#ffb936d0",
            })
                .width("100%")
                .height("70%")
                .padding({ left: 16, right: 16 })
            Row() {
                Button('PreIndex')
                    .fontSize(16)
                    .padding(16)
                    .onClick(() => {
                        let temp = this.testIndex - 1
                        if (temp < 0) {
                            temp = 0
                        }
                        this.testIndex = temp
                    })
                Button('NextIndex')
                    .fontSize(16)
                    .padding(16)
                    .onClick(() => {
                        let temp = this.testIndex + 1
                        if (temp > this.lrcList.length - 1) {
                            temp = this.lrcList.length - 1
                        }
                        this.testIndex = temp
                    }).margin({ left: 16 })
                Button('AutoPlay')
                    .fontSize(16)
                    .padding(16)
                    .onClick(() => {
                        this.test()
                    }).margin({ left: 16 })
            }
            .width("100%")
            .justifyContent(FlexAlign.Center)
            .margin({ top: 36 })

            Text(this.duration / 1000 + "s")
                .fontSize(18)
                .margin({ top: 16 })

            Slider({
                style: SliderStyle.InSet,
                max: this.lrcList[this.lrcList.length-1].timestamp,
                value: this.duration
            })
                .width("100%")
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == 3) {
                        console.debug("---------" + value)
                        this.duration = value
                    }
                })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
    }
}