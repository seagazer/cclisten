import { CcPlayer, PlayerType } from '@seagazer/ccplayer'

export class MediaPlayer {
    private static ccplayer: CcPlayer = null

    private constructor() {
    }

    public static getInstance(): CcPlayer {
        if (this.ccplayer == null) {
            this.ccplayer = CcPlayer.create(PlayerType.AUDIO)
        }
        return this.ccplayer
    }
}