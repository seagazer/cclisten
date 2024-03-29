import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { PageRouter } from '../extensions/PageRouter';
import aac from '@ohos.abilityAccessCtrl'
import { MediaSession } from '../player/MediaSession';
import { Logger } from '../extensions/Logger';
import { BackgroundTask } from '../extensions/BackgroundTask';
import errorManager from '@ohos.app.ability.errorManager';
import { PlaylistManager } from '../playlist/PlaylistManager';
import { ThemeManager } from '../theme/ThemeManager';
import { Theme } from '../theme/Theme';
import { Platform } from '../base/Platform';
import { PlayHistoryManager } from '../history/PlayHistoryManager';

const TAG = "[MainAbility]"

export default class EntryAbility extends UIAbility {
    private mediaSession: MediaSession = null

    onCreate(want, launchParam) {
        Platform.init()
        // init
        this.mediaSession = MediaSession.get()
        this.mediaSession.initAvSession(this.context)
        BackgroundTask.getInstance().init(this.context)
        PlaylistManager.get().init(this.context)
        PlayHistoryManager.get().init(this.context)
        ThemeManager.get().init(this.context)
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
            statusBarColor: Theme.APP_BACKGROUND_COLOR,
            navigationBarColor: Theme.APP_BACKGROUND_COLOR,
            statusBarContentColor: Theme.APP_SYSTEM_COLOR,
            navigationBarContentColor: Theme.APP_SYSTEM_COLOR
        })
        windowStage.loadContent(PageRouter.PAGE_SPLASH)
    }

    onDestroy() {
        Logger.d(TAG, "onDestroy: release player.")
        this.mediaSession.release()
    }
}
