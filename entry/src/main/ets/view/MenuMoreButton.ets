import { navigationTo, toast } from '../extensions/Extensions'
import { APP_THEME } from '../extensions/LiveData'
import { PageRouter } from '../extensions/PageRouter'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { StatelessImageButton } from './StatelessImageButton'

@Component
export struct MenuMoreButton {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME

    @Builder
    MenuMore() {
        Column() {
            Row() {
                Image($r("app.media.ic_public_themes")).width(24).height(24).margin({ right: 12 })
                Text("主题设置").fontSize(16)
            }
            .width('100%')
            .height(32)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
                navigationTo(PageRouter.PAGE_SETTINGS_THEME, {
                    THEME_COLOR: this.theme.colorPrimary
                })
            })

            Divider().width("100%").height(1).margin({ top: 8, bottom: 8 })
            Row() {
                Image($r("app.media.ic_public_albums")).width(24).height(24).margin({ right: 12 })
                Text("媒体库").fontSize(16)
            }
            .width('100%')
            .height(32)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
                toast("TODO")
            })

            Divider().width("100%").height(1).margin({ top: 8, bottom: 8 })
            Row() {
                Image($r("app.media.ic_public_app")).width(24).height(24).margin({ right: 12 })
                Text("关于").fontSize(16)
            }
            .width('100%')
            .height(32)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
                navigationTo(PageRouter.PAGE_SETTINGS_ABOUT)
            })
        }
        .width(160)
        .padding(8)
    }

    build() {
        StatelessImageButton({ image: $r("app.media.ic_public_more") })
            .bindMenu(this.MenuMore)


    }
}