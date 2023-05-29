import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
    onCreate(want, launchParam) {
    }

    onDestroy() {
    }

    onWindowStageCreate(windowStage: window.WindowStage) {
        windowStage.loadContent("splash/Splash", (err, data) => {
            if (err.code) {
                return
            }
        })
    }

    onWindowStageDestroy() {
    }

    onForeground() {
    }

    onBackground() {
    }
}
