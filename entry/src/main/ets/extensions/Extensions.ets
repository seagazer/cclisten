import Prompt from '@system.prompt'

export function toast(message: string, duration: number = 2000) {
    Prompt.showToast({
        message: message,
        duration: duration
    })
}

export function duration2time(duration: number): string {
    let minute = ~~(duration / 1000 / 60)
    let second = ~~(duration / 1000 - minute * 60)
    let s1 = minute.toString()
    let s2 = second > 10 ? second.toString() : "0" + second
    return s1 + ":" + s2
}