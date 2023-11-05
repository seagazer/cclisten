import { UIConfig } from '../config/UIConfig'
import { DEFAULT_THEME } from '../theme/Theme'
import router from '@ohos.router'

@Component
export struct SettingsItemView {
    icon: ResourceStr = ""
    title: string = ""
    target: string = ""

    @Styles
    pressedStyles() {
        .border({ radius: UIConfig.DIMENSION_CORNER })
        .backgroundColor(DEFAULT_THEME.colorAction)
    }

    @Styles
    normalStyles() {
        .backgroundColor(null)
    }

    build() {
        Column() {
            Row() {
                Image(this.icon).width(50).height(50)
                Text(this.title).fontSize(UIConfig.FONT_SUB_TITLE).height(56).margin({ left: 16 }).layoutWeight(1)
                Image($r("app.media.baseline_keyboard_arrow_right_24"))
                    .width(56)
                    .height("100%")
                    .padding(12)
            }
        }
        .width("100%")
        .height(64)
        .padding({ left: 8, right: 8 })
        .stateStyles({
            normal: this.normalStyles,
            pressed: this.pressedStyles
        })
        .onClick(() => {
            router.pushUrl({
                url: this.target
            })
        })
    }
}