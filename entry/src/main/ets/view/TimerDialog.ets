import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { Fab } from './Fab'

@CustomDialog
export struct TimerDialog {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    controller: CustomDialogController
    onAction: (minute: number) => void
    private countDownMinute: number = 5
    private themeColor: string = ""

    aboutToAppear() {
        this.themeColor = this.theme.colorPrimary
    }

    build() {
        Column() {
            Text("请输入倒计时")
                .fontSize(20)

            TextInput({ placeholder: "5分钟" })
                .type(InputType.Number)
                .margin({ top: 48 })
                .onChange((value) => {
                    this.countDownMinute = Number.parseFloat(value)
                })

            Row() {
                Fab({
                    text: "确认",
                    textSize: 18,
                    color: this.themeColor,
                    onAction: () => {
                        if (this.countDownMinute > 0) {
                            this.onAction?.(this.countDownMinute)
                        } else {
                            this.controller.close()
                        }
                    }
                })
                Fab({
                    text: "取消",
                    textSize: 18,
                    color: "#ff7c7c7c",
                    marginSize: { left: 32 },
                    onAction: () => {
                        this.controller.close()
                    }
                })
            }
            .margin({ top: 16 })
            .justifyContent(FlexAlign.Center)

        }
        .padding(16)
    }
}