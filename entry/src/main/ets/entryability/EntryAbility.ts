import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { PageRouter } from '../extensions/PageRouter';
import aac from '@ohos.abilityAccessCtrl'

export default class EntryAbility extends UIAbility {
    onCreate(want, launchParam) {
        aac.createAtManager()
            .requestPermissionsFromUser(this.context, ["ohos.permission.READ_MEDIA", "ohos.permission.READ_AUDIO"])
    }

    onWindowStageCreate(windowStage: window.WindowStage) {
        windowStage.loadContent(PageRouter.PAGE_SPLASH, () => {
        })
        let win = windowStage.getMainWindowSync()
        win.setWindowSystemBarProperties({
            statusBarColor: "#ffffff",
            navigationBarColor: "#ffffff",
            statusBarContentColor: "#ff575757",
            navigationBarContentColor: "#ff575757"
        })
    }
}
