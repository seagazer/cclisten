import image from '@ohos.multimedia.image'

/**
 * Author: seagazer
 * Date: 2023/9/21
 */
export class PixelMapFactory {
    static async decodeFile(filePath: string, options?: image.SourceOptions) {
        try {
            let imageSource = options ? image.createImageSource(filePath, options) : image.createImageSource(filePath)
            return await imageSource.createPixelMap()
        } catch (err) {
            return null
        }
    }

    static async decodeStream(stream: ArrayBuffer, options?: image.SourceOptions) {
        try {
            let imageSource = options ? image.createImageSource(stream, options) : image.createImageSource(stream)
            return await imageSource.createPixelMap()
        } catch (err) {
            return null
        }
    }
}