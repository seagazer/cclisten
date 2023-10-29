import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { TimerDialog } from '../view/TimerDialog'
import common from '@ohos.app.ability.common'
import { UIConfig } from '../config/UIConfig'

const TAG = "[PageMore]"

@Preview
@Component
export struct PageMore {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    private timerDialogController = new CustomDialogController({
        builder: TimerDialog({ onAction: (minute) => {
            this.startCountDownTimer(minute)
            this.timerDialogController.close()
        } }),
        autoCancel: true,
        customStyle: true
    })
    private countDownTimer = -1
    @State countDownValue: string = ""

    @Styles
    pressedStyles() {
        .border({ radius: UIConfig.DIMENSION_CORNER })
        .backgroundColor(DEFAULT_THEME.colorAction)
    }

    @Styles
    normalStyles() {
        .backgroundColor(null)
    }

    @Builder
    ThemeSetting() {
        Row() {
            Image($r("app.media.baseline_settings_24")).width(32).height(32)
            Text("主题设置").height(56).margin({ left: 16 }).layoutWeight(1)
            Image($r("app.media.baseline_keyboard_arrow_right_24"))
                .width(56)
                .height(56)
                .padding(12)
        }
        .width("100%")
        .height(56)
        .padding({ left: 8, right: 8 })
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
        .onClick(() => {
            // todo
        })
    }

    @Builder
    ShutdownSetting() {
        Row() {
            Image($r("app.media.baseline_av_timer_24")).width(32).height(32)
                .fillColor(this.countDownValue != "" ? this.theme.colorSecondary : Color.Black)
            Text(this.countDownValue != "" ? `剩余${this.countDownValue}关闭` : "定时关闭")
                .height(56)
                .fontColor(this.countDownValue != "" ? this.theme.colorPrimary : Color.Black)
                .margin({ left: 16 })
                .layoutWeight(1)
            Image(this.countDownValue != "" ? $r("app.media.baseline_clear_24") : $r("app.media.baseline_keyboard_arrow_right_24"))
                .width(56)
                .height(56)
                .padding(12)
                .fillColor(this.countDownValue != "" ? this.theme.colorPrimary : Color.Black)
                .onClick(() => {
                    clearInterval(this.countDownTimer)
                    this.countDownValue = ""
                })
        }
        .width("100%")
        .height(56)
        .padding({ left: 8, right: 8 })
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
        .onClick(() => {
            this.timerDialogController.open()
        })
    }

    @Builder
    PlaylistSetting() {
        Row() {
            Image($r("app.media.baseline_list_24")).width(32).height(32)
            Text("播放列表").height(56).margin({ left: 16 }).layoutWeight(1)
            Image($r("app.media.baseline_keyboard_arrow_right_24"))
                .width(56)
                .height(56)
                .padding(12)
        }
        .width("100%")
        .height(56)
        .padding({ left: 8, right: 8 })
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
        .onClick(() => {
            // todo
        })
    }

    @Builder
    StorageSetting() {
        Row() {
            Image($r("app.media.baseline_sd_storage_24")).width(32).height(32)
            Text("数据管理").height(56).margin({ left: 16 }).layoutWeight(1)
            Image($r("app.media.baseline_keyboard_arrow_right_24"))
                .width(56)
                .height(56)
                .padding(12)
        }
        .width("100%")
        .height(56)
        .padding({ left: 8, right: 8 })
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
        .onClick(() => {
            // todo
        })
    }

    @Builder
    LanguageSetting() {
        Row() {
            Image($r("app.media.baseline_language_24")).width(32).height(32)
            Text("语言设置").height(56).margin({ left: 16 }).layoutWeight(1)
            Image($r("app.media.baseline_keyboard_arrow_right_24"))
                .width(56)
                .height(56)
                .padding(12)
        }
        .width("100%")
        .height(56)
        .padding({ left: 8, right: 8 })
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
        .onClick(() => {
            // todo
        })
    }

    @Builder
    AboutSetting() {
        Row() {
            Image($r("app.media.baseline_tips_and_updates_24")).width(32).height(32)
            Text("关于").height(56).margin({ left: 16 }).layoutWeight(1)
            Image($r("app.media.baseline_keyboard_arrow_right_24"))
                .width(56)
                .height(56)
                .padding(12)
        }
        .width("100%")
        .height(56)
        .padding({ left: 8, right: 8 })
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
        .onClick(() => {
            // todo
        })
    }

    @Builder
    LineSpace() {
        Divider().height(1).width("95%").margin({ top: 4, bottom: 4 })
    }

    build() {
        Column() {
            this.ThemeSetting()
            this.LineSpace()
            this.ShutdownSetting()
            this.LineSpace()
            this.PlaylistSetting()
            this.LineSpace()
            this.StorageSetting()
            this.LineSpace()
            this.LanguageSetting()
            this.LineSpace()
            this.AboutSetting()
        }
        .width("100%")
        .height("100%")
        .alignItems(HorizontalAlign.Start)
        .padding(32)
    }

    private startCountDownTimer(minute: number) {
        clearInterval(this.countDownTimer)
        let current = new Date().getTime()
        let shutDownTime = minute * 60 * 1000 + current
        let curSeconds = Math.floor(minute * 60)
        this.countDownValue = curSeconds <= 60 ? curSeconds + "秒" : Math.round(curSeconds / 60) + "分"
        this.countDownTimer = setInterval(() => {
            let current = new Date().getTime()
            let seconds = Math.floor((shutDownTime - current) / 1000)
            this.countDownValue = seconds <= 60 ? seconds + "秒" : Math.round(seconds / 60) + "分"
            if (current >= shutDownTime) {
                clearInterval(this.countDownTimer)
                let ctx = getContext(this) as common.UIAbilityContext
                ctx.terminateSelf()
            }
        }, 1000)
    }

    aboutToDisappear() {
        clearInterval(this.countDownTimer)
        // delete this.timerDialogController
        // this.timerDialogController = null
    }
}