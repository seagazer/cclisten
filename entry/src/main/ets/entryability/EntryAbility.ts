import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { PageRouter } from '../extensions/PageRouter';

export default class EntryAbility extends UIAbility {
    onCreate(want, launchParam) {
    }

    onDestroy() {
    }

    onWindowStageCreate(windowStage: window.WindowStage) {
        windowStage.loadContent(PageRouter.PAGE_HOME, () => {
        })
        let win = windowStage.getMainWindowSync()
        win.setWindowSystemBarProperties({
            statusBarColor: "#ffffff",
            navigationBarColor: "#ffffff",
            statusBarContentColor: "#ff575757",
            navigationBarContentColor: "#ff575757"
        })
    }

    onWindowStageDestroy() {
    }

    onForeground() {
    }

    onBackground() {
    }
}
