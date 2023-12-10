import { Song } from '../bean/Song'
import { UIConfig } from '../config/UIConfig'
import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { Fab } from './Fab'

@Preview
@CustomDialog
export struct DeleteDialog {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    controller: CustomDialogController
    @Prop song: Song
    onAction = (song: Song) => {
    }

    build() {
        Column() {
            Text("以下歌曲将从列表中删除")
                .fontSize(UIConfig.FONT_SUB_TITLE)
                .width("100%")
                .textAlign(TextAlign.Start)

            Row() {
                Image($r("app.media.ic_normal_white_grid_audio"))
                    .width(32).height(36)
                Text(this.song.title)
                    .fontSize(UIConfig.FONT_CONTENT)
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 12 })
            }
            .margin({ top: 32, bottom: 8 })
            .justifyContent(FlexAlign.Center)

            Row() {
                Fab({
                    text: "确认",
                    textSize: UIConfig.FONT_BUTTON,
                    onAction: () => {
                        this.onAction(this.song)
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