import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { TimerDialog } from '../view/TimerDialog'
import common from '@ohos.app.ability.common'
import { UIConfig } from '../config/UIConfig'
import { SettingsItemView } from '../view/SettingsItemView'
import { seconds2text } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'

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
    @State countDownText: string = ""

    @Builder
    ShutdownSetting() {
        Row() {
            Image($r("app.media.baseline_av_timer_24")).width(32).height(32)
                .fillColor(this.countDownText != "" ? this.theme.colorSecondary : Color.Black)
            Text("定时关闭")
                .height(56)
                .fontColor(this.countDownText != "" ? this.theme.colorPrimary : Color.Black)
                .margin({ left: 16 })
                .layoutWeight(1)
            if (this.countDownText != "") {
                Text(this.countDownText)
                    .height(56)
                    .fontColor(this.theme.colorPrimary)
                    .margin({ right: 8 })
            }
            Image(this.countDownText != "" ? $r("app.media.baseline_clear_24") : $r("app.media.baseline_keyboard_arrow_right_24"))
                .width(56)
                .height(56)
                .padding(12)
                .fillColor(this.countDownText != "" ? this.theme.colorPrimary : Color.Black)
                .onClick(() => {
                    clearInterval(this.countDownTimer)
                    this.countDownText = ""
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

    build() {
        Column() {
            SettingsItemView({
                icon: $r("app.media.baseline_list_24"),
                title: "媒体库",
                target: PageRouter.PAGE_MEDIA_LIBRARY
            })
            SettingsItemView({
                icon: $r("app.media.baseline_settings_24"),
                title: "主题设置",
                target: PageRouter.PAGE_THEME_SETTINGS
            })
            SettingsItemView({
                icon: $r("app.media.baseline_sd_storage_24"),
                title: "数据管理",
                target: PageRouter.PAGE_STORAGE_SETTINGS
            })
            SettingsItemView({
                icon: $r("app.media.baseline_language_24"),
                title: "语言设置",
                target: PageRouter.PAGE_LANGUAGE_SETTINGS
            })
            this.ShutdownSetting()
            SettingsItemView({
                icon: $r("app.media.baseline_tips_and_updates_24"),
                title: "关于",
                target: PageRouter.PAGE_ABOUT
            })
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
        this.countDownText = seconds2text(minute * 60)
        this.countDownTimer = setInterval(() => {
            let current = new Date().getTime()
            let seconds = Math.floor((shutDownTime - current) / 1000)
            this.countDownText = seconds2text(seconds)
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

    @Styles
    pressedStyles() {
        .border({ radius: UIConfig.DIMENSION_CORNER })
        .backgroundColor(DEFAULT_THEME.colorAction)
    }

    @Styles
    normalStyles() {
        .backgroundColor(null)
    }
}