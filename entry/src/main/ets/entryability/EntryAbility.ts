import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
    onCreate(want, launchParam) {
    }

    onDestroy() {
    }

    onWindowStageCreate(windowStage: window.WindowStage) {
        windowStage.loadContent("splash/Splash", () => {
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
