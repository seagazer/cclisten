import common from '@ohos.app.ability.common'
import { Logger } from './Logger'
import wantAgent from '@ohos.app.ability.wantAgent'
import backgroundTaskManager from '@ohos.resourceschedule.backgroundTaskManager'
import bundleManager from '@ohos.bundle.bundleManager'


const TAG = "[BackgroundTask]"

/**
 * Author: seagazer
 * Date: 2023/9/21
 */
export class BackgroundTask {
    private context: common.Context
    private hapInfo: bundleManager.BundleInfo
    private static sInstance: BackgroundTask = null

    private constructor() {
    }

    public static getInstance() {
        if (!this.sInstance) {
            this.sInstance = new BackgroundTask()
        }
        return this.sInstance
    }

    public init(context: common.Context) {
        this.context = context
    }

    async startBackgroundTask() {
        try {
            if (!this.context) {
                Logger.e(TAG, "The context is null, must call @link{init(context: common.Context)} first!")
                return
            }
            if (!this.hapInfo) {
                this.hapInfo = await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_HAP_MODULE)
            }
            if (this.hapInfo.hapModulesInfo.length > 0) {
                let bundle = this.hapInfo.name
                let mainAbility = this.hapInfo.hapModulesInfo[0].mainElementName
                Logger.d(TAG, "start background task param= " + bundle + "/" + mainAbility)
                let wantParams = await wantAgent.getWantAgent(
                    {
                        wants: [
                            {
                                bundleName: bundle,
                                abilityName: mainAbility
                            }
                        ],
                        operationType: wantAgent.OperationType.START_ABILITY,
                        requestCode: 0,
                        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
                    })
                await backgroundTaskManager.startBackgroundRunning(this.context, backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantParams)
            }
        } catch (err) {
            Logger.e(TAG, "start background task error= " + JSON.stringify(err))
        }
    }

    async stopBackgroundTask() {
        try {
            Logger.d(TAG, "stop background task")
            await backgroundTaskManager.stopBackgroundRunning(this.context)
        } catch (err) {
            Logger.e(TAG, "stop background task error= " + JSON.stringify(err))
        }
    }
}