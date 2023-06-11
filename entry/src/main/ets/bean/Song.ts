export class Song {
    url: string
    title: string
    artist: string
    duration: number

    constructor(url: string, title: string = "", artist: string = "", duration: number = 0) {
        this.url = url
        this.title = title
        this.artist = artist
        this.duration = duration
    }
}