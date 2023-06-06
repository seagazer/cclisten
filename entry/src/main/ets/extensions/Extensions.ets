import Prompt from '@system.prompt'
import { PageRouter } from './PageRouter'
import router from '@ohos.router'
import { Logger } from './Logger'

export function toast(message: string, duration: number = 2000) {
    Prompt.showToast({
        message: message,
        duration: duration
    })
}

const TAG = "[Extensions]"

export function navigationTo(pageUrl: PageRouter) {
    Logger.d(TAG, "navigation to <" + pageUrl.toString() + ">")
    router.pushUrl({
        url: pageUrl.toString()
    })
}

export function duration2text(duration: number): string {
    let seconds = Math.round(duration / 1000)
    let minute = Math.floor(seconds / 60)
    let second = seconds - minute * 60
    let s1 = minute.toString()
    let s2 = second >= 10 ? second.toString() : "0" + second
    return s1 + ":" + s2
}