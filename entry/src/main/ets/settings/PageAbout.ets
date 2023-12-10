import { UIConfig } from '../config/UIConfig'
import bundleManager from '@ohos.bundle.bundleManager'
import { Logger } from '../extensions/Logger'
import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'

const TAG = "[PageAbout]"
const Developer = "Develop by Seagazer"
const Github = "https://github.com/seagazer"

@Entry
@Component
struct PageAbout {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @State appName: string = "Listen"
    @State appVersion: string = "Version 1.0.0"

    pageTransition() {
        PageTransitionEnter({ duration: 300 }).opacity(0).scale({ x: 0.75, y: 0.75 })
        PageTransitionExit({ duration: 300 }).opacity(0).scale({ x: 0.75, y: 0.75 })
    }

    aboutToAppear() {
        this.getAppInfo()
    }

    async getAppInfo() {
        let bundleInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
        this.appVersion = "Version " + bundleInfo.versionName
        Logger.d(TAG, "The app version is " + this.appVersion + ", app name is " + this.appName)
    }

    build() {
        Column() {
            Column() {
                Image($r("app.media.ic_launcher_large")).width(96).height(96)

                Text(this.appName).fontWeight(FontWeight.Bold).fontSize(UIConfig.FONT_TITLE).margin({ top: 32 })

                Text(this.appVersion).fontSize(UIConfig.FONT_SUB_TITLE).margin({ top: 4 })
            }
            .width("100%")
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)

            Text(Developer)
                .fontStyle(FontStyle.Italic)
                .textAlign(TextAlign.Center).fontSize(UIConfig.FONT_CONTENT)
            Text(Github)
                .fontColor("#cc8a8a8a")
                .textAlign(TextAlign.Center).fontSize(UIConfig.FONT_SUB_CONTENT)
                .margin({ top: 4, bottom: 16 })
        }
        .width('100%')
        .height('100%')
        .padding(UIConfig.DIMENSION_PADDING)
    }
}