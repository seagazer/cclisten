import { UIConfig } from '../config/UIConfig'
import bundleManager from '@ohos.bundle.bundleManager'
import { Logger } from '../extensions/Logger'

const TAG = "[PageAbout]"

@Entry
@Component
struct PageAbout {
    @State appName: string = "Listen"
    @State appVersion: string = "Version 1.0.0"

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
                Image($r('app.media.ic_launcher')).width(96).height(96)

                Text(this.appName).fontWeight(FontWeight.Bold).fontSize(UIConfig.FONT_TITLE).margin({ top: 32 })

                Text(this.appVersion).fontSize(UIConfig.FONT_SUB_TITLE).margin({ top: 4 })
            }
            .width("100%")
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)

            Text("Develop by Seagazer")
                .fontStyle(FontStyle.Italic)
                .textAlign(TextAlign.Center).fontSize(UIConfig.FONT_CONTENT)
            Text("https://github.com/seagazer")
                .fontColor("#cc8a8a8a")
                .textAlign(TextAlign.Center).fontSize(UIConfig.FONT_SUB_CONTENT)
                .margin({ top: 4, bottom: 16 })
        }
        .width('100%')
        .height('100%')
        .padding(UIConfig.DIMENSION_PADDING)
    }
}