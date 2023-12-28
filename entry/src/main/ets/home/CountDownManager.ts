import worker, { MessageEvents } from '@ohos.worker'
import { Logger } from '../extensions/Logger'
import common from '@ohos.app.ability.common'

const TAG = "[CountDownManager]"

export const MSG_SHUTDOWN = "shutDown"

/**
 * The manager to create or destroy a thread to do auto shut down task.
 *
 * Author: seagazer
 * Date: 2023/12/24
 */
export class CountDownManager {
    private countDownThread?: worker.ThreadWorker = undefined
    private onUpdate: (time: string) => void = (_: string) => {
    }

    constructor(onUpdate: (time: string) => void) {
        this.onUpdate = onUpdate
    }

    startCountDownThread(context: common.UIAbilityContext, minute: number) {
        this.stopCountDownThread()
        this.countDownThread = new worker.ThreadWorker("entry/ets/workers/TimerWorker.ts")
        this.countDownThread!.onmessage = (event: MessageEvents) => {
            if (event.data == MSG_SHUTDOWN) {
                Logger.w(TAG, "count down finish, going shutDown!")
                this.stopCountDownThread()
                context.terminateSelf()
            } else {
                let timeStr = event.data as string
                this.onUpdate(timeStr)
            }
        }
        this.countDownThread!.postMessage(minute)
    }

    stopCountDownThread() {
        if (this.countDownThread) {
            this.countDownThread!.terminate()
            this.onUpdate("")
            this.countDownThread = undefined
        }
    }
}