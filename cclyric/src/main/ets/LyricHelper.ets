import { Lyric } from './bean/Lyric'
import { printD } from './extensions/Extension'

/**
 * The helper to get lyric line by media position.
 */
export class LyricHelper {
    private currentIndex = 0
    private currentLyric = ""
    private lrcList: Array<Lyric> = new Array<Lyric>()

    private getIndex(position: number): number {
        let first = this.lrcList[0].timestamp
        if (position < first) {
            return 0
        }
        let last = this.lrcList[this.lrcList.length-1].timestamp
        if (position > last) {
            return this.lrcList.length - 1
        }
        for (let i = 0; i < this.lrcList.length - 1; i++) {
            let l1 = this.lrcList[i].timestamp
            let l2 = this.lrcList[i+1].timestamp
            if (position > l1 && position < l2) {
                return i
            }
        }
        return this.currentIndex
    }

    /**
     * Setup the lyric list.
     * @param data The list of lyric.
     */
    public setLyricData(data: Array<Lyric>) {
        this.lrcList = data
        this.currentIndex = 0
        this.currentLyric = ""
    }

    /**
     * Get the lyric text from current media progress.
     * @param position The position of the player.
     * @returns The lyric text current time.
     */
    public getLyric(position: number): string {
        let index = this.getIndex(position)
        if (index != this.currentIndex) {
            printD("next line=" + index)
            this.currentLyric = this.lrcList[index].text
            this.currentIndex = index
        }
        return this.currentLyric
    }
}