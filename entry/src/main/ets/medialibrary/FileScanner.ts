import fs from '@ohos.file.fs'
import mediaLibrary from '@ohos.multimedia.mediaLibrary'
import common from '@ohos.app.ability.common'

/**
 * Author: seagazer
 * Date: 2023/6/11
 */
export class FileScanner {
    static async scan(root: string, format: Array<string> = [".mp3"]) {
        let files = await fs.listFile(root, {
            filter: {
                suffix: format
            }
        })
        let result = new Array<string>()
        files.forEach((file) => {
            result.push(root + "/" + file)
        })
        return result.sort((a, b) => {
            return Number.parseInt(a) - Number.parseInt(b)
        })
    }

    static async scanLyric(root: string, key: string) {
        let files = await fs.listFile(root, {
            filter: {
                suffix: [".lrc"]
            }
        })
        let lyricPath: string = null
        for (let i = 0;i < files.length; i++) {
            let f = files[i]
            if (f.indexOf(key) >= 0) {
                lyricPath = f
                break
            }
        }
        return root + "/" + lyricPath
    }

    static async scanMediaLibrary(context: common.Context) {
        let mediaLib = mediaLibrary.getMediaLibrary(context)
        let fileKeyObj = mediaLibrary.FileKey
        let fetchOp = {
            selections: `${fileKeyObj.MEDIA_TYPE}=?`,
            selectionArgs: [mediaLibrary.MediaType.AUDIO + ""],
        }
        let fileResult = await mediaLib.getFileAssets(fetchOp)
        let audioList = await fileResult.getAllObject()
        return audioList
    }
}