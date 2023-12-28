import { UIConfig } from '../config/UIConfig'
import { APP_THEME, COUNT_DOWN_TIMER, LiveData } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { Fab } from './Fab'

@Preview
@CustomDialog
export struct TimerDialog {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @StorageLink(COUNT_DOWN_TIMER) selectIndex: number = -1
    @Link countDown: string
    @State isCountDowning: boolean = false
    @State selectTime: string = "选择时间"
    private timeList: Array<number> = [10, 20, 30, 45, 60, 90]
    private scaleSize = 1.15
    controller: CustomDialogController
    onAction: (minute: number) => void = () => {
    }
    private currentSelectDuration: number = -1
    private isUserChanged = false

    aboutToAppear() {
        this.isCountDowning = this.countDown != ""
        this.currentSelectDuration = this.timeList[this.selectIndex]
    }

    build() {
        Column() {
            Text("定时关闭")
                .fontSize(UIConfig.FONT_SUB_TITLE)

            Row() {
                if (this.isCountDowning) {
                    Text(this.countDown).fontSize(UIConfig.FONT_CONTENT).layoutWeight(1)
                } else {
                    Text(this.selectTime).fontSize(UIConfig.FONT_CONTENT).layoutWeight(1)
                }
                Toggle({ type: ToggleType.Switch, isOn: this.selectIndex != -1 }).selectedColor(this.theme.colorPrimary)
                    .onChange((isOn) => {
                        this.isUserChanged = true
                        if (isOn) {
                            if (this.selectIndex == -1) {
                                this.selectIndex = 0
                                this.currentSelectDuration = this.timeList[this.selectIndex]
                                this.selectTime = this.currentSelectDuration + "min"
                            }
                        } else {
                            this.selectIndex = -1
                            this.currentSelectDuration = -1
                            this.selectTime = "选择时间"
                            this.isCountDowning = false
                        }
                    })
            }.padding(16)

            Row() {
                ForEach(this.timeList, (time: number, index: number) => {
                    Text(time.toString())
                        .textAlign(TextAlign.Center)
                        .width(40)
                        .height(40)
                        .fontColor(index == this.selectIndex ? "#ffffff" : "#000000")
                        .backgroundColor(index == this.selectIndex ? this.theme.colorPrimary : "#cce0e0e0")
                        .border({ radius: 100 })
                        .scale({
                            x: this.selectIndex == index ? this.scaleSize : 1,
                            y: this.selectIndex == index ? this.scaleSize : 1
                        })
                        .animation({
                            duration: UIConfig.ANIM_DURATION
                        })
                        .onClick(() => {
                            this.isUserChanged = true
                            this.isCountDowning = false
                            this.selectIndex = index
                            this.currentSelectDuration = this.timeList[this.selectIndex]
                            this.selectTime = this.currentSelectDuration + "min"
                        })

                })
            }
            .justifyContent(FlexAlign.SpaceAround)
            .width("100%")

            Row() {
                Fab({
                    text: "确认",
                    textSize: UIConfig.FONT_BUTTON,
                    onAction: () => {
                        if (this.isUserChanged) {
                            LiveData.setValue<number>(COUNT_DOWN_TIMER, this.selectIndex)
                            this.onAction(this.currentSelectDuration)
                        }
                        this.controller.close()
                    }
                })
                Fab({
                    text: "取消",
                    textSize: UIConfig.FONT_BUTTON,
                    marginSize: { left: 32 },
                    onAction: () => {
                        this.controller.close()
                    }
                })
            }
            .margin({ top: 32 })
            .justifyContent(FlexAlign.Center)

        }
        .padding(32)
        .width(400)
        .backgroundColor(Color.White)
        .border({ radius: UIConfig.DIMENSION_CORNER })
    }
}