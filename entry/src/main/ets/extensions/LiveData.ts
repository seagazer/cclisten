export class LiveData {
    static setValue<T>(key: string, value: T) {
        AppStorage.Set<T>(key, value)
    }
}

export const APP_THEME = "APP_THEME"

export const MEDIA_SESSION_PLAYING_STATE = "IS_PLAYING"

export const MEDIA_SESSION_POSITION = "CUR_POSITION"

export const MEDIA_SESSION_DURATION = "TOTAL_DURATION"

export const MEDIA_SESSION_TITLE = "TITLE"

export const MEDIA_SESSION_ARTIST = "ARTIST"

export const MEDIA_SESSION_CURRENT_SONG = "CURRENT_SONG"

export const MEDIA_SESSION_FILE_LIST = "FILE_LIST"
