import Prompt from '@system.prompt'

export function toast(message: string, duration: number = 2000) {
    Prompt.showToast({
        message: message,
        duration: duration
    })
}