import { IParser, Lyric, LyricParser } from '@seagazer/cclyric';
import fs from '@ohos.file.fs'

export class FileParser implements IParser {
    private parser = new LyricParser()

    parse(filePath: string): Lyric {
        let lrc = fs.readTextSync(filePath)
        let lrcArray = lrc.split("\n")
        return this.parser.parse(lrcArray)
    }
}