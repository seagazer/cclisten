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
        this.db.addColumn("isFavourite", "INTEGER")
        await this.db.create(context, "playlist")
    }

    public async addSong(song: Song) {
        await this.db.insert(song)
    }

    public async addSongList(songList: Array<Song>) {
        await this.db.insertArray(songList)
    }

    public async removeSong(song: Song) {
        await this.db.delete("url", song)
    }

    public async update(song: Song) {
        await this.db.update("url", song)
    }

    public async getPlaylist() {
        return this.db.query()
    }
}