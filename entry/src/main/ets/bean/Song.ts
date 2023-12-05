//@ts-ignore
@Observed
export class Song {
    url: string
    title: string
    artist: string
    duration: number
    isAdd: number = 0 // 1 added,0 not add
    isFavourite: number = 0 // 1 liked,0 not liked

    constructor(url: string, title: string = "", artist: string = "", duration: number = 0) {
        this.url = url
        this.title = title
        this.artist = artist
        this.duration = duration
    }
}