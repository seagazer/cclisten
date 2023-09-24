import { Song } from '../bean/Song'
import { DbHelper } from '../extensions/DbHelper'
import common from '@ohos.app.ability.common'

export class PlaylistDb {
    private db = new DbHelper<Song>()

    public async init(context: common.Context) {
        this.db.addTableColumn("url", "TEXT")
        this.db.addTableColumn("title", "TEXT")
        this.db.addTableColumn("artist", "TEXT")
        this.db.addTableColumn("duration", "TEXT")
        await this.db.createTable(context, "playlist")
    }

    public addSong(song: Song) {
        this.db.insert(song)
    }

    public addSongList(songList: Array<Song>) {
        this.db.insertArray(songList)
    }

    public removeSong(song: Song) {
        this.db.delete(song, "url")
    }

    public getPlaylist() {
        return this.db.query()
    }
}