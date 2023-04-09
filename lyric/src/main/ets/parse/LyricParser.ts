import { IParser } from './IParser';
import { Lyric } from '../bean/Lyric';

export class LyricParser implements IParser {
    parse(src: Array<string>): Array<Lyric> {
        let result = new Array<Lyric>()
        src.forEach((line) => {
            let spr = line.split(']')
            let text = spr[1]
            let spr1 = spr[0]
            let spr1_1 = spr1.replace('[', "") //00:00.50
            let spr2 = spr1_1.split(':')
            let spr2_1 = spr2[0] //00
            let minute = Number.parseInt(spr2_1)
            let spr2_2 = spr2[1] //00.50
            let spr3 = spr2_2.split(".")
            let spr3_1 = spr3[0] //00
            let spr3_2 = spr3[1] //50
            let seconds = Number.parseInt(spr3_1)
            let millionSecond = Number.parseInt(spr3_2)
            let timestamp = minute * 60000 + seconds * 1000 + millionSecond
            result.push(new Lyric(timestamp, text))
        })
        return result
    }
}