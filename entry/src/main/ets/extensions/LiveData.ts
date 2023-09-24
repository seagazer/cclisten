export class LiveData {
    static setValue<T>(key: string, value: T) {
        AppStorage.setOrCreate<T>(key, value)
    }
}

export const APP_THEME = "APP_THEME"

export const MEDIA_SESSION_PLAYING_STATE = "IS_PLAYING"

export const MEDIA_SESSION_POSITION = "CUR_POSITION"

export const MEDIA_SESSION_CURRENT_SONG = "CURRENT_SONG"

export const MEDIA_SESSION_PLAYLIST = "PLAYLIST"
