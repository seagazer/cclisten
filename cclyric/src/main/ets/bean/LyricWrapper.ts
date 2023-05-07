import { Lyric } from './Lyric';

export class LyricWrapper extends Lyric {
    readonly height: number

    constructor(src: Lyric, height: number) {
        super(src.timestamp, src.text)
        this.height = height
    }
}