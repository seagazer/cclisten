import worker, { ThreadWorkerGlobalScope, MessageEvents, ErrorEvent } from '@ohos.worker';


/**
 * The thread to do auto shut down task for CountDownManager.
 *
 * Author: seagazer
 * Date: 2023/12/24
 */

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

function seconds2text(seconds: number) {
    let minute = Math.floor(seconds / 60)
    let second = seconds - minute * 60
    if (second < 10) {
        return minute + ":0" + second
    } else {
        return minute + ":" + second
    }
}

let timer = -1

workerPort.onmessage = function (e: MessageEvents) {
    let minute = e.data as number
    let seconds = minute * 60
    clearInterval(timer)
    timer = setInterval(() => {
        seconds--
        if (seconds == 0) {
            clearInterval(timer)
            workerPort.postMessage("shutDown")
            return
        }
        let str = seconds2text(seconds)
        workerPort.postMessage(str)
    }, 1000)
}

workerPort.onmessageerror = function (e: MessageEvents) {
}

workerPort.onerror = function (e: ErrorEvent) {
}