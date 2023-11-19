import { Song } from '../bean/Song'
import { DbHelper } from '../base/DbHelper'
import common from '@ohos.app.ability.common'

/**
 * The manager to manage a playlist of user.
 *
 * Author: seagazer
 * Date: 2023/6/4
 */
export class PlaylistDb {
    private db = new DbHelper<Song>()

    public async init(context: common.Context) {
        this.db.addColumn("url", "TEXT")
        this.db.addColumn("title", "TEXT")
        this.db.addColumn("artist", "TEXT")
        this.db.addColumn("duration", "INTEGER")
        await this.db.create(context, "playlist")
    }

    public addSong(song: Song) {
        this.db.insert(song)
    }

    public addSongList(songList: Array<Song>) {
        this.db.insertArray(songList)
    }

    public removeSong(song: Song) {
        this.db.delete("url", song)
    }

    public getPlaylist() {
        return this.db.query()
    }
}