import fs from '@ohos.file.fs'

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
        return result
    }
}