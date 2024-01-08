import { Song } from '../bean/Song'
import { UIConfig } from '../config/UIConfig'
import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { Fab } from './Fab'

@Preview
@CustomDialog
export struct RefreshDialog {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    controller: CustomDialogController
    onAction: () => void = () => {
    }

    build() {
        Column() {
            Text("即将刷新列表，此操作会清除当前播放及收藏列表，是否确认?")
                .fontSize(UIConfig.FONT_SUB_TITLE)
                .width("100%")
                .textAlign(TextAlign.Start)

            Row() {
                Fab({
                    text: "确认",
                    textSize: UIConfig.FONT_BUTTON,
                    onAction: () => {
                        this.onAction()
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