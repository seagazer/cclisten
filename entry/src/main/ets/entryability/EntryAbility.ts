import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { PageRouter } from '../extensions/PageRouter';
import aac from '@ohos.abilityAccessCtrl'
import { MediaSession } from '../player/MediaSession';
import { Logger } from '../extensions/Logger';
import { BackgroundTask } from '../extensions/BackgroundTask';
import errorManager from '@ohos.app.ability.errorManager';

const TAG = "[MainAbility]"

export default class EntryAbility extends UIAbility {
    private mediaSession: MediaSession = null

    onCreate(want, launchParam) {
        // init media session
        this.mediaSession = MediaSession.get()
        this.mediaSession.initAvSession(this.context)
        BackgroundTask.getInstance().init(this.context)
        // request permission
        aac.createAtManager()
            .requestPermissionsFromUser(this.context, ["ohos.permission.READ_MEDIA", "ohos.permission.READ_AUDIO"])
        // init error handler
        errorManager.on("error", {
            onUnhandledException(errMsg) {
                Logger.e(TAG, "app cause un catch error= " + errMsg)
            }
        })
    }

    onWindowStageCreate(windowStage: window.WindowStage) {
        let win = windowStage.getMainWindowSync()
        win.setWindowSystemBarProperties({
            statusBarColor: "#ffffff",
            navigationBarColor: "#ffffff",
            statusBarContentColor: "#ff575757",
            navigationBarContentColor: "#ff575757"
        })
        windowStage.loadContent(PageRouter.PAGE_SPLASH)
    }

    onDestroy() {
        Logger.d(TAG, "onDestroy: release player.")
        this.mediaSession.release()
    }
}
