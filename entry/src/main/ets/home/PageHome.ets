import router from '@ohos.router';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { MediaController } from '../view/MediaController';
import { LyricController, LyricView } from '@seagazer/cclyric';
import { dimColor, navigationTo, toast } from '../extensions/Extensions';
import { Logger } from '../extensions/Logger';
import { FileScanner } from '../extensions/FileScanner';
import { FileLyricParser } from '../player/FileLyricParser';
import { Song } from '../bean/Song';
import { APP_THEME, LiveData, MEDIA_SESSION_CURRENT_SONG, MEDIA_SESSION_PLAYLIST } from '../extensions/LiveData';
import { MediaSession } from '../player/MediaSession';
import { PlaylistItemView } from '../view/PlaylistItemView';
import { PlaylistManager } from '../playlist/PlaylistManager';
import { PlayHistoryManager } from '../history/PlayHistoryManager';
import { UIConfig } from '../config/UIConfig';
import { History } from '../bean/History';
import { LoopMode } from '../player/LoopMode';
import { AnimCoverView } from '../view/AnimCoverView';
import { MediaProgressView } from '../view/MediaProgressView';
import { StatefulImageButton } from '../view/StatefulImageButton';
import { StatelessImageButton } from '../view/StatelessImageButton';
import { TimerDialog } from '../view/TimerDialog';
import { PageRouter } from '../extensions/PageRouter';
import { DeleteDialog } from '../view/DeleteDialog';
import { FavouriteItemView } from '../view/FavouriteItemView';
import { SelectableImageButton } from '../view/SelectableImageButton';

const TAG = "[PageHome]"


@Entry
@Component
struct PageHome {
    @StorageLink(APP_THEME) @Watch("onThemeChanged") theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_CURRENT_SONG) @Watch("onSongChanged") currentSong: Song = new Song("", "", "", 0)
    @StorageLink(MEDIA_SESSION_PLAYLIST) playlist: Array<Song> = new Array()
    @State currentPosition: number = 0
    @State isPlaying: boolean = false
    @State playingIndex: number = 0
    @Watch("onLoopModeChanged") @State loopMode: LoopMode = LoopMode.LOOP_ALL
    @State isShowLyric: boolean = false
    @State isShowPlaylist: boolean = false
    @State isNotPlayed: boolean = true
    @State deleteSong?: Song = undefined
    @State curTabIndex: number = 0
    private mediaSession: MediaSession = MediaSession.get()
    private historyManager: PlayHistoryManager = PlayHistoryManager.get()
    private playlistManager: PlaylistManager = PlaylistManager.get()
    private lyricController: LyricController = new LyricController()
    private lyricParser: FileLyricParser = new FileLyricParser()
    private playlistScroller = new Scroller()
    private timerDialogController = new CustomDialogController({
        builder: TimerDialog({
            onAction: (minute) => {
                if (minute > 0) {
                    this.timerIcon = $r("app.media.ic_public_clock_filled")
                    this.isTiming = true
                } else {
                    this.timerIcon = $r("app.media.ic_public_clock")
                    this.isTiming = false
                }
            }
        }),
        autoCancel: false,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -32 }
    })
    private deleteDialogController = new CustomDialogController({
        builder: DeleteDialog({
            song: this.deleteSong,
            onAction: (song: Song) => {
                if (this.currentSong.url == song.url) {
                    this.playlistManager.setPlayingSong(null)
                    this.mediaSession.playNext()
                }
                this.playlistManager.remove(song)
                this.playingIndex = this.playlistManager.getPlayingIndex()
            }
        }),
        autoCancel: true,
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: -32 }
    })
    @State favouriteIcon: Resource = $r("app.media.ic_public_favor")
    @State timerIcon: Resource = $r("app.media.ic_public_clock")
    @State lyricIcon: Resource = $r("app.media.ic_public_text")

    pageTransition() {
        PageTransitionEnter({ duration: 300 }).opacity(0).scale({ x: 0.75, y: 0.75 })
        PageTransitionExit({ duration: 300 }).opacity(0).scale({ x: 0.75, y: 0.75 })
    }

    aboutToAppear() {
        router.clear()
        let param = router.getParams() as Record<string, Object>
        Logger.d(TAG, "router param= " + JSON.stringify(param))
        if (param.song) {
            let song = param.song as Song
            if (song) {
                this.mediaSession.playSong(song)
                LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, song)
                this.isNotPlayed = false
            }
        } else if (param.history) {
            let history = param.history as History
            if (history) {
                Logger.d(TAG, "read history = " + JSON.stringify(history))
                this.loopMode = history.loopMode
                LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, history.song)
                this.mediaSession.setLoopMode(history.loopMode)
                this.playlistManager.setPlayingSong(history.song)
                this.playingIndex = this.playlistManager.getIndex(history.song)
            }
        }
        this.mediaSession.initAvSession(getContext(this))
        this.mediaSession.onProgressChanged((position) => {
            this.currentPosition = position
            if (this.isShowLyric) {
                this.lyricController.updatePosition(this.currentPosition)
            }
        })
        this.mediaSession.onStateChanged((isPlaying: boolean) => {
            this.isPlaying = isPlaying
        })
        this.lyricController
            .setTextSize(vp2px(18))
            .setCacheSize(10)
            .setAnimationDuration(400)
            .setTextColor("#ccc1c1c1")
            .setHighlightColor(this.theme.colorPrimary)
            .setLineSpace(vp2px(16))
            .setHighlightStyle(false)
            .setEmptyHint("暂无歌词")
            .setLyric(null)
            .setAlignMode("center")
    }

    onThemeChanged() {
        this.lyricController.setHighlightColor(this.theme.colorPrimary)
        this.lyricController.updatePosition(this.currentPosition)
    }

    onBackPress() {
        if (this.isShowPlaylist) {
            this.isShowPlaylist = false
            return true
        }
        return false
    }

    @Builder
    MediaTitle() {
        Column() {
            Text(this.currentSong.title)
                .fontSize(UIConfig.FONT_TITLE)
                .fontColor(this.theme.colorPrimary)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(this.currentSong.artist)
                .fontSize(UIConfig.FONT_CONTENT)
                .fontColor(dimColor(this.theme.colorPrimary, 0.9))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 8 })
        }
    }

    @Builder
    MediaCoverView() {
        Column() {
            // cover image
            AnimCoverView({
                isAnim: this.isPlaying && !this.isShowLyric,
                viewSize: 360,
                animEdge: 64,
                animDuration: 4000
            })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.SpaceAround)
        .visibility(this.isShowLyric ? Visibility.Hidden : Visibility.Visible)
    }

    @Builder
    LyricContainer() {
        Column() {
            LyricView({ lyricController: this.lyricController })
        }
        .width("100%")
        .height("100%")
        .visibility(this.isShowLyric ? Visibility.Visible : Visibility.Hidden)
    }

    @Builder
    MenuMore() {
        Column() {
            Row() {
                Image($r("app.media.ic_public_themes")).width(24).height(24).margin({ right: 12 })
                Text("主题设置").fontSize(16)
            }
            .width('100%')
            .height(32)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
                navigationTo(PageRouter.PAGE_SETTINGS_THEME, {
                    THEME_COLOR: this.theme.colorPrimary
                })
            })

            Divider().width("100%").height(1).margin({ top: 8, bottom: 8 })
            Row() {
                Image($r("app.media.ic_public_albums")).width(24).height(24).margin({ right: 12 })
                Text("媒体库").fontSize(16)
            }
            .width('100%')
            .height(32)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
                toast("TODO")
            })

            Divider().width("100%").height(1).margin({ top: 8, bottom: 8 })
            Row() {
                Image($r("app.media.ic_public_app")).width(24).height(24).margin({ right: 12 })
                Text("关于").fontSize(16)
            }
            .width('100%')
            .height(32)
            .justifyContent(FlexAlign.Start)
            .alignItems(VerticalAlign.Center)
            .onClick(() => {
                navigationTo(PageRouter.PAGE_SETTINGS_ABOUT)
            })
        }
        .width(160)
        .padding(8)
    }

    @State isFavourite: boolean = false
    @State isTiming: boolean = false

    @Builder
    ActionContainer() {
        Row() {
            SelectableImageButton({ image: this.favouriteIcon, isSelected: this.isFavourite })
                .onClick(() => {
                    if (this.currentSong.isFavourite == 1) {
                        this.currentSong.isFavourite = 0
                        this.isFavourite = false
                        this.favouriteIcon = $r("app.media.ic_public_favor")
                    } else {
                        this.currentSong.isFavourite = 1
                        this.isFavourite = true
                        this.favouriteIcon = $r("app.media.ic_public_favor_filled")
                    }
                    this.playlistManager.updateSong(this.currentSong)
                })
            SelectableImageButton({ image: this.timerIcon, isSelected: this.isTiming })
                .onClick(() => {
                    this.timerDialogController.open()
                })
            SelectableImageButton({ image: this.lyricIcon, isSelected: this.isShowLyric })
                .onClick(() => {
                    if (this.isShowLyric) {
                        this.isShowLyric = false
                        this.lyricIcon = $r('app.media.ic_public_text')
                    } else {
                        if (this.isShowPlaylist) {
                            return
                        }
                        this.isShowLyric = true
                        this.lyricController.updatePosition(this.currentPosition)
                        this.lyricIcon = $r('app.media.ic_public_text_filled')
                    }
                })
            StatelessImageButton({ image: $r("app.media.ic_public_more") })
                .bindMenu(this.MenuMore)
        }
        .width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 8, bottom: 12 })
    }

    private deleteAction(song: Song) {
        this.deleteSong = song
        this.deleteDialogController.open()
    }

    @Builder
    TabTitle(title: string, index: number) {
        Text(title).fontSize(UIConfig.FONT_SUB_TITLE)
            .fontColor(this.curTabIndex == index ? this.theme.colorPrimary : "#cc3e3e3e")
    }

    @Builder
    PlaylistContainer() {
        Panel(true) {
            Tabs() {
                TabContent() {
                    List({ scroller: this.playlistScroller }) {
                        ForEach(this.playlist, (song: Song, index: number) => {
                            if (this.playingIndex == index) {
                                ListItem() {
                                    PlaylistItemView({
                                        data: song,
                                        isHighLight: true,
                                        onAction: (song: Song) => {
                                            this.mediaSession.playSong(song)
                                        },
                                        onDelete: (song: Song) => {
                                            this.deleteAction(song)
                                        }
                                    })
                                }
                            } else {
                                ListItem() {
                                    PlaylistItemView({
                                        data: song,
                                        isHighLight: false,
                                        onAction: (song: Song) => {
                                            this.mediaSession.playSong(song)
                                        },
                                        onDelete: (song: Song) => {
                                            this.deleteAction(song)
                                        }
                                    })
                                }
                            }
                        })
                    }
                    .padding({ left: 16, right: 16, top: 8 })
                    .scrollBar(BarState.Auto)
                    .width("100%")
                    .height("100%")
                    .onAppear(() => {
                        this.playlistScroller.scrollToIndex(this.playingIndex)
                    })
                }.tabBar(this.TabTitle("播放列表", 0))
                .tabIndex(0)

                TabContent() {
                    List({ scroller: this.playlistScroller }) {
                        ForEach(this.playlistManager.getFavouriteList(), (song: Song) => {
                            ListItem() {
                                FavouriteItemView({ data: song, isHighLight: false,
                                    onAction: (song: Song) => {
                                        this.mediaSession.playSong(song)
                                    },
                                    onFavourite: (song: Song) => {
                                    }
                                })
                            }
                        })
                    }
                    .padding({ left: 16, right: 16, top: 8 })
                    .scrollBar(BarState.Auto)
                    .width("100%")
                    .height("100%")
                }.tabBar(this.TabTitle("我的收藏", 1))
                .tabIndex(1)
            }
            .barMode(BarMode.Fixed)
            .barHeight(32)
            .animationDuration(300)
            .onChange((index) => {
                this.curTabIndex = index
            })
            .onAppear(() => {
                this.curTabIndex = 0
            })
        }
        .mode(PanelMode.Full)
        .type(PanelType.Minibar)
        .fullHeight(500)
        .miniHeight(0)
        .backgroundColor("#fff8f8f8")
        .onChange((_, __, mode) => {
            if (mode == PanelMode.Mini) {
                this.isShowPlaylist = false
            }
        })
    }

    build() {
        Stack() {
            Column() {
                // media title
                this.MediaTitle()
                Stack() {
                    // cover
                    this.MediaCoverView()
                    // lyricView
                    this.LyricContainer()
                }
                .width("100%")
                .layoutWeight(1)

                // actions buttons
                this.ActionContainer()
                // progress
                MediaProgressView({
                    currentSong: this.currentSong,
                    currentPosition: this.currentPosition,
                    onSeekChanged: (position: number) => {
                        this.mediaSession.seekTo(position)
                    }
                })
                // controller button
                MediaController({
                    isPlaying: this.isPlaying,
                    loopMode: this.loopMode,
                    actionPlay: () => {
                        if (this.isNotPlayed && this.currentSong) {
                            this.mediaSession.playSong(this.currentSong)
                            this.isNotPlayed = false
                            return
                        }
                        if (this.mediaSession.isPlaying()) {
                            this.mediaSession.pause()
                        } else {
                            this.mediaSession.start()
                        }
                    },
                    actionPlayNext: () => {
                        this.mediaSession.playNext()
                    },
                    actionPlayPre: () => {
                        this.mediaSession.playPre()
                    },
                    actionPlaylist: () => {
                        this.isShowPlaylist = true
                    }
                })
            }
            .width('100%')
            .height('100%')
            .padding(16)

            // playlist
            if (this.isShowPlaylist) {
                this.PlaylistContainer()
            }
        }
        .alignContent(Alignment.Bottom)
        .width('100%')
        .height('100%')
    }

    onSongChanged() {
        Logger.d(TAG, "onSongChanged= " + JSON.stringify(this.currentSong))
        this.playingIndex = this.playlistManager.getPlayingIndex()
        this.lyricController.setLyric(null)
        let filePath = FileScanner.scanLyricSync(getContext(this).filesDir, this.currentSong.title)
        Logger.d(TAG, "update lyric= " + filePath)
        if (filePath) {
            let lrc = this.lyricParser.parse(filePath)
            if (lrc) {
                this.lyricController.setLyric(lrc)
            }
        } else {
            Logger.e(TAG, "get lyric error!")
        }
        // save history when song changed, so the history is not loss if the app crash
        this.saveHistory()
        // refresh favourite ui
        if (this.currentSong.isFavourite == 1) {
            this.favouriteIcon = $r("app.media.ic_public_favor_filled")
            this.isFavourite = true
        } else {
            this.favouriteIcon = $r("app.media.ic_public_favor")
            this.isFavourite = false
        }
    }

    private async saveHistory() {
        let history = new History(this.loopMode, this.currentSong)
        Logger.d(TAG, "save play history= " + JSON.stringify(history))
        await this.historyManager.saveHistory(history)
    }

    onLoopModeChanged() {
        this.mediaSession.setLoopMode(this.loopMode)
        this.playingIndex = this.playlistManager.getPlayingIndex()
    }

    aboutToDisappear() {
        this.saveHistory()
    }
}