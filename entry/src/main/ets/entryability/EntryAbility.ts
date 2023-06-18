import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { PageRouter } from '../extensions/PageRouter';
import aac from '@ohos.abilityAccessCtrl'
import { MediaSession } from '../player/MediaSession';
import { Logger } from '../extensions/Logger';

const TAG = "[MainAbility]"

export default class EntryAbility extends UIAbility {
    private mediaSession: MediaSession = null
    private isBackToLauncher = false

    onCreate(want, launchParam) {
        this.mediaSession = MediaSession.get()
        aac.createAtManager()
            .requestPermissionsFromUser(this.context, ["ohos.permission.READ_MEDIA", "ohos.permission.READ_AUDIO"])
    }

    onWindowStageCreate(windowStage: window.WindowStage) {
        windowStage.loadContent(PageRouter.PAGE_SPLASH)
        let win = windowStage.getMainWindowSync()
        win.setWindowSystemBarProperties({
            statusBarColor: "#ffffff",
            navigationBarColor: "#ffffff",
            statusBarContentColor: "#ff575757",
            navigationBarContentColor: "#ff575757"
        })
    }

    onForeground() {
        Logger.d(TAG, "onForeground: resume player.")
        if (this.isBackToLauncher) {
            this.mediaSession.start()
            this.isBackToLauncher = false
        }
    }

    onBackground() {
        Logger.d(TAG, "onBackground: pause player.")
        if (this.mediaSession.isPlaying()) {
            this.mediaSession.pause()
            this.isBackToLauncher = true
        }
    }

    onDestroy() {
        Logger.d(TAG, "onDestroy: release player.")
        this.mediaSession.release()
    }
}
