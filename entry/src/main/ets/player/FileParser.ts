import { IParser, Lyric, LyricParser } from '@seagazer/cclyric';
import fs from '@ohos.file.fs'
import { Logger } from '../extensions/Logger';

const TAG = "FileParser"

/**
 * Author: seagazer
 * Date: 2023/6/11
 */
export class FileParser implements IParser {
    private parser = new LyricParser()

    parse(filePath: string): Lyric {
        let lrc = fs.readTextSync(filePath)
        let isCR = lrc.indexOf("\r") > 0 && lrc.indexOf("\n") < 0 // mac
        let isLF = lrc.indexOf("\n") > 0 && lrc.indexOf("\r") < 0 // unix
        let isCRLF = lrc.indexOf("\r") > 0 && lrc.indexOf("\n") > 0 // windows
        let lrcArray = []
        if (isCR) {
            Logger.d(TAG, "isCR mac")
            lrcArray = lrc.split("\r")
        } else if (isLF) {
            Logger.d(TAG, "isLF unix")
            lrcArray = lrc.split("\n")
        } else if (isCRLF) {
            Logger.d(TAG, "isCRLF windows")
            lrcArray = lrc.split("\r\n")
        }
        return this.parser.parse(lrcArray)
    }
}