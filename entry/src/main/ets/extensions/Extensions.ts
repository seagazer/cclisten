import Prompt from '@system.prompt'
import { PageRouter } from './PageRouter'
import router from '@ohos.router'
import { Logger } from './Logger'
import fs from '@ohos.file.fs'

const TAG = "[Extensions]"

export function toast(message: string, duration: number = 2000) {
    Prompt.showToast({
        message: message,
        duration: duration
    })
}

/**
 * Parse the uri to fd.
 * @param uri The uri of media file.
 * @returns The fd of media file.
 */
export async function parseUri(uri: string) {
    let file = await fs.open(uri)
    return file.fd
}

export function navigationTo(pageUrl: PageRouter, param?: Object) {
    Logger.d(TAG, "navigation to <" + pageUrl.toString() + ">, param= " + JSON.stringify(param))
    router.pushUrl({
        url: pageUrl.toString(),
        params: param
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

/**
 * Modify the color and dim with a factor in [0,1].
 * @param color The origin color to be dim.
 * @param factor The dim percent, the value is [0,1] and default value is 1 with no dim.
 * @returns The dim color.
 */
export function dimColor(color: number | string, factor: number = 1): number {
    if (typeof color == 'string') {
        let hexString = color.replace("#", "")
        if (hexString.length < 8) {
            hexString = "ff" + hexString
        }
        color = Number.parseInt(hexString, 16)
    }
    // hex to argb
    let alpha = color >> 24 & 0xff
    let red = color >> 16 & 0xff
    let green = color >> 8 & 0xff
    let blue = color & 0xff
    // dim
    red *= factor
    green *= factor
    blue *= factor
    if (red < 0) red = 0
    if (red > 255) red = 255
    if (green < 0) green = 0
    if (green > 255) green = 255
    if (blue < 0) blue = 0
    if (blue > 255) blue = 255
    // argb to hex
    return alpha << 24 | red << 16 | green << 8 | blue
}