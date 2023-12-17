import { Platform } from '../base/Platform'

export class LiveData {
    static setValue<T>(key: string, value: T) {
        if (Platform.apiVersion() > 9) {
            AppStorage.setOrCreate<T>(key, value)
        } else {
            AppStorage.SetOrCreate<T>(key, value)
        }
    }
}

export const APP_THEME = "APP_THEME"

export const MEDIA_SESSION_CURRENT_SONG = "CURRENT_SONG"

export const MEDIA_SESSION_PLAYLIST = "PLAYLIST"
export const MEDIA_SESSION_FAVOURITE_LIST = "FAVOURITE_LIST"
