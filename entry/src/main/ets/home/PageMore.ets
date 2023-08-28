import { DEFAULT_THEME } from '../theme/Theme'

const TAG = "[PageMore]"

@Preview
@Component
export struct PageMore {
    @Styles
    pressedStyles() {
        .border({ radius: 4 })
        .backgroundColor(DEFAULT_THEME.colorAction)
    }

    @Styles
    normalStyles() {
        .backgroundColor(null)
    }

    build() {
        Column() {
            Row() {
                Image($r("app.media.baseline_settings_24")).width(32).height(32)
                Text("主题设置").height(56).margin({ left: 16 }).layoutWeight(1)
                Image($r("app.media.baseline_keyboard_arrow_right_24")).width(32).height(32)
                    .fillColor("#ff8c8c8c")
            }.width("100%").height(56)
            .padding({ left: 8, right: 8 })
            .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
            })

            Divider().height(1).width("100%").margin({ top: 4, bottom: 4 })
            Row() {
                Image($r("app.media.baseline_av_timer_24")).width(32).height(32)
                Text("定时关闭").height(56).margin({ left: 16 }).layoutWeight(1)
                Image($r("app.media.baseline_keyboard_arrow_right_24")).width(32).height(32)
                    .fillColor("#ff8c8c8c")
            }.width("100%").height(56)
            .padding({ left: 8, right: 8 })
            .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
            })

            Divider().height(1).width("100%").margin({ top: 4, bottom: 4 })
            Row() {
                Image($r("app.media.baseline_list_24")).width(32).height(32)
                Text("播放列表").height(56).margin({ left: 16 }).layoutWeight(1)
                Image($r("app.media.baseline_keyboard_arrow_right_24")).width(32).height(32)
                    .fillColor("#ff8c8c8c")
            }.width("100%").height(56)
            .padding({ left: 8, right: 8 })
            .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
            })

            Divider().height(1).width("100%").margin({ top: 4, bottom: 4 })
            Row() {
                Image($r("app.media.baseline_sd_storage_24")).width(32).height(32)
                Text("数据管理").height(56).margin({ left: 16 }).layoutWeight(1)
                Image($r("app.media.baseline_keyboard_arrow_right_24")).width(32).height(32)
                    .fillColor("#ff8c8c8c")
            }.width("100%").height(56)
            .padding({ left: 8, right: 8 })
            .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
            })

            Divider().height(1).width("100%").margin({ top: 4, bottom: 4 })
            Row() {
                Image($r("app.media.baseline_language_24")).width(32).height(32)
                Text("语言设置").height(56).margin({ left: 16 }).layoutWeight(1)
                Image($r("app.media.baseline_keyboard_arrow_right_24")).width(32).height(32)
                    .fillColor("#ff8c8c8c")
            }.width("100%").height(56)
            .padding({ left: 8, right: 8 })
            .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
            })


            Divider().height(1).width("100%").margin({ top: 4, bottom: 4 })
            Row() {
                Image($r("app.media.baseline_tips_and_updates_24")).width(32).height(32)
                Text("关于").height(56).margin({ left: 16 }).layoutWeight(1)
                Image($r("app.media.baseline_keyboard_arrow_right_24")).width(32).height(32)
                    .fillColor("#ff8c8c8c")
            }.width("100%").height(56)
            .padding({ left: 8, right: 8 })
            .stateStyles({
                normal: this.normalStyles,
                pressed: this.pressedStyles
            })
        }
        .width("100%")
        .height("100%")
        .alignItems(HorizontalAlign.Start)
        .padding(32)
    }
}