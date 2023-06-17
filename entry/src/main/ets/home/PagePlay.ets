import { MediaControlBar } from '../view/MediaControlBar';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { Lyric, LyricConfig, LyricHelper, LyricView } from '@seagazer/cclyric';
import { duration2text as timeToString } from '../extensions/Extensions';
import { CcPlayer, MediaSourceFactory, PlayerType } from '@seagazer/ccplayer';
import { LoopMode } from '../player/LoopMode';
import { Logger } from '../extensions/Logger';
import { PlaylistManager } from '../playlist/PlaylistManager';
import mediaLibrary from '@ohos.multimedia.mediaLibrary';
import { FileScanner } from '../medialibrary/FileScanner';
import { FileParser } from '../player/FileParser';

const TAG = "[PagePlay]"


// hdc file send C:\Users\seagazer\Desktop\画心.lrc /data/app/el2/100/base/com.seagazer.listen/haps/entry/files/

@Entry
@Component
struct PagePlay {
    @StorageLink("theme") theme: Theme = DEFAULT_THEME
    @State isPlaying: boolean = false
    @State title: string = ""
    @State artist: string = ""
    @State animAlpha: number = 1
    @State lyricLine: string = " "
    @State isShowLyric: boolean = false
    private lyricConfig: LyricConfig = new LyricConfig()
    private lyricHelper: LyricHelper
    private player: CcPlayer = null
    private playlist: PlaylistManager = PlaylistManager.get()
    @State currentPosition: number = 0
    @State totalDuration: number = 0
    private loopMode: LoopMode = LoopMode.PLAYLIST_LOOP
    private isInit = true
    private progressChangedListener = (duration: number) => {
        if (!this.isSeeking) {
            this.currentPosition = duration
            this.lyricConfig.updatePosition(duration)
            this.lyricLine = this.lyricHelper.getLyric(duration)
        }
    }
    private prepareListener = () => {
        this.isInit = false
        this.isSeeking = false
        this.isPlaying = true
        this.currentPosition = 0
        this.lyricLine = " "
        this.totalDuration = this.player.getDuration()
        let lyricData = this.lyricList[this.currentPlayIndex]
        Logger.d(TAG, "prepared lyricList size= " + this.lyricList.length)
        this.lyricConfig.setLyric(null)
        this.lyricHelper.setLyricData(null)
        if (lyricData) {
            this.lyricConfig.setLyric(lyricData)
            if (lyricData.lyricList.length > 0) {
                this.lyricHelper.setLyricData(lyricData.lyricList)
            }
        }
        Logger.d(TAG, "prepared index= " + this.currentPlayIndex + ", curPosition= " + this.currentPosition)
    }
    private completedListener = () => {
        this.currentPosition = this.player.getDuration()
        this.isPlaying = this.player.isPlaying()
        Logger.d(TAG, "completed, play mode= " + this.loopMode + ", curPosition= " + this.currentPosition)
        switch (this.loopMode) {
            case LoopMode.PLAYLIST_LOOP:
                this.playNext()
                break
            case LoopMode.LOOP:
                this.player.start()
                break
            case LoopMode.SHUFFLE:
                break
        }
    }
    private lyricList = new Array<Lyric>()
    private lyricParser: FileParser
    private currentPlayIndex = 0
    private isSeeking = false
    @StorageLink("currentSong") currentSong: mediaLibrary.FileAsset = null
    @StorageLink("fileList") fileList: Array<mediaLibrary.FileAsset> = new Array()

    private async prepareData() {
        if (this.currentSong) {
            Logger.d(TAG, "init song= " + JSON.stringify(this.currentSong.title))
            this.totalDuration = this.currentSong.duration
            this.title = this.currentSong.title
            this.artist = this.currentSong.artist
            this.playlist.add(this.currentSong)
            let result = await  FileScanner.scanLyric(getContext(this).filesDir, this.currentSong.title)
            Logger.d(TAG, "lyric file= " + result)
            let lrc = this.lyricParser.parse(result)
            Logger.d(TAG, "lrc= " + lrc.artist)
            this.lyricList.push(lrc)
            Logger.w(TAG, "lyric list= " + JSON.stringify(this.lyricList))

        }
    }

    aboutToAppear() {
        this.player = CcPlayer.create(PlayerType.AUDIO)
        this.lyricHelper = new LyricHelper()
        this.lyricParser = new FileParser()

        this.prepareData()

        this.player
            .addOnProgressChangedListener(this.progressChangedListener)
            .addOnPreparedListener(this.prepareListener)
            .addOnCompletionListener(this.completedListener)
            .addOnSeekChangedListener(() => {
                this.isSeeking = false
                Logger.d(TAG, "---seek completed")
            })
        this.lyricConfig
            .setTextSize(vp2px(16))
            .setCacheSize(4)
            .setTextColor(this.theme.colorSecondary)
            .setHighlightColor(this.theme.colorPrimary)
            .setLineSpace(vp2px(14))
            .setHighlightStyle(false)
            .setEmptyHint("暂无歌词")
    }

    aboutToDisappear() {
        this.player
            .removeOnPreparedListener(this.prepareListener)
            .removeOnProgressChangedListener(this.progressChangedListener)
            .removeOnCompletionListener(this.completedListener)
            .release()
    }

    @Styles pressedStyles() {
        .border({ radius: 200 })
        .backgroundColor(this.theme.colorAction)
    }

    @Styles normalStyles() {
        .border({ radius: 200 })
        .backgroundColor(null)
    }

    @Builder
    Title() {
        Column() {
            Text(this.title).fontSize(24).fontColor(this.theme.colorPrimary)
            Text(this.artist).fontSize(14).fontColor(this.theme.colorSecondary)
                .margin({ top: 8 })
        }
    }

    @Builder
    ProgressBar() {
        Column() {
            // slider
            Slider(
                {
                    style: SliderStyle.OutSet,
                    min: 0,
                    max: this.totalDuration,
                    value: this.currentPosition
                })
                .width('100%')
                .trackColor(this.theme.colorPrimary)
                .blockColor(this.theme.colorPrimary)
                .selectedColor(this.theme.colorSecondary)
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                        Logger.d(TAG, "seek to " + value + ", mode=" + mode + ", curPosition=" + this.currentPosition)
                        this.isSeeking = true
                        this.player.seekTo(value)
                    }
                })
            // duration
            Row() {
                Text(timeToString(this.currentPosition)).fontSize(14).fontColor(this.theme.colorSecondary)
                Text(timeToString(this.totalDuration)).fontSize(14).fontColor(this.theme.colorSecondary)
            }.width('100%')
            .alignItems(VerticalAlign.Bottom)
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 8, right: 8 })
        }.padding({ left: 16, right: 16 })
    }

    @Builder
    Cover() {
        Stack() {
            Image($r("app.media.ic_cover"))
                .objectFit(ImageFit.Cover)
                .width("100%")
                .aspectRatio(1)
                .margin(32)
        }
        .width(300)
        .aspectRatio(1)
        .border({ radius: 4 })
        .shadow({ radius: 12, color: "#ff848484" })
        .backgroundColor("#ffbce5e8")
    }

    build() {
        Stack() {
            Column() {
                // title
                this.Title()

                Stack() {
                    Column() {
                        // cover image
                        this.Cover()
                        // lyric
                        Text(this.lyricLine).fontSize(16).height(20).fontColor(this.theme.colorSecondary)
                    }
                    .width("100%")
                    .height("100%")
                    .justifyContent(FlexAlign.SpaceEvenly)
                    .opacity(this.animAlpha)
                    .animation({
                        duration: 300,
                        curve: Curve.Linear,
                        delay: 0,
                        iterations: 1, // 设置-1表示动画无限循环
                        playMode: PlayMode.Normal
                    })
                    .onClick(() => {
                        this.showLyric()
                    })

                    Column() {
                        LyricView({ lyricConfig: this.lyricConfig })
                    }
                    .width("100%")
                    .height("100%")
                    .padding(32)
                    .opacity(1 - this.animAlpha)
                    .animation({
                        duration: 300,
                        curve: Curve.Linear,
                        delay: 0,
                        iterations: 1, // 设置-1表示动画无限循环
                        playMode: PlayMode.Normal
                    })
                    .onClick(() => {
                        this.showLyric()
                    })
                }
                .width("100%")
                .layoutWeight(1)

                // progress
                this.ProgressBar()
                // controller button
                MediaControlBar({
                    isPlaying: $isPlaying,
                    actionPlayOrPause: this.playOrPause.bind(this),
                    actionPlayNext: this.playNext.bind(this),
                    actionPlayPre: this.playPre.bind(this),
                    onModeChanged: this.onModeChanged.bind(this)
                })
            }
            .width('100%')
            .height('100%')
            .padding(16)
            .alignItems(HorizontalAlign.Center)
        }
        .alignContent(Alignment.TopEnd)
        .width('100%')
        .height('100%')
    }

    private async playOrPause() {
        if (this.player.isPlaying()) {
            this.player.pause()
            this.isPlaying = false
        } else {
            if (this.isInit && this.currentSong) {
                let song = this.currentSong
                Logger.d(TAG, "init play = " + song.title)
                let fd = await song.open("r")
                let source = MediaSourceFactory.createUrl("fd://" + fd, song.title)
                this.player.setMediaSource(source, () => {
                    this.player.start()
                })
            } else {
                this.player.start()
            }
            this.isPlaying = true
        }
    }

    private showLyric() {
        this.isShowLyric = !this.isShowLyric
        this.animAlpha = this.isShowLyric ? 0 : 1
    }

    private onModeChanged(mode: LoopMode) {
        this.loopMode = mode
    }

    private playNext() {
        this.currentPlayIndex++
        if (this.currentPlayIndex > this.playlist.size() - 1) {
            this.currentPlayIndex = 0
        }
        let song = this.playlist.getSong(this.currentPlayIndex)
        Logger.d(TAG, "play next=" + this.currentPlayIndex + ", " + JSON.stringify(song))
        this.playSong(song)
    }

    private playPre() {
        this.currentPlayIndex--
        if (this.currentPlayIndex < 0) {
            this.currentPlayIndex = this.playlist.size() - 1
        }
        let song = this.playlist.getSong(this.currentPlayIndex)
        Logger.d(TAG, "play pre=" + this.currentPlayIndex + ", " + JSON.stringify(song))
        this.playSong(song)
    }

    private async playSong(song: mediaLibrary.FileAsset) {
        this.title = song.title
        this.artist = song.artist
        let fd = await song.open("r")
        let source = MediaSourceFactory.createUrl("fd://" + fd, song.title)
        this.player.setMediaSource(source, () => {
            this.player.start()
        })
    }
}