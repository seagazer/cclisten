import systemParameterEnhance from '@ohos.systemParameterEnhance'
import { Logger } from '../extensions/Logger'

const TAG = "[Platform]"

/**
 * Author: seagazer
 * Date: 2023/8/27
 */
export class Platform {
    private static sApiVersion: number

    static init() {
        this.sApiVersion = Number.parseInt(systemParameterEnhance.getSync("const.ohos.apiversion", "9"))
        Logger.d(TAG, "The api version = " + this.sApiVersion)
    }

    static apiVersion() {
        return this.sApiVersion
    }
}