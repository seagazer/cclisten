import Prompt from '@system.prompt'

export function toast(message: string, duration: number = 2000) {
    Prompt.showToast({
        message: message,
        duration: duration
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