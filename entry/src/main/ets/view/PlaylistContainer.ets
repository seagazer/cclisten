import { Song } from '../bean/Song'
import { UIConfig } from '../config/UIConfig'
import { APP_THEME, MEDIA_SESSION_FAVOURITE_LIST, MEDIA_SESSION_PLAYLIST } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { FavouriteItemView } from './FavouriteItemView'
import { PlaylistItemView } from './PlaylistItemView'

@Component
export struct PlaylistContainer {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @StorageLink(MEDIA_SESSION_PLAYLIST) playlist: Array<Song> = new Array()
    @StorageLink(MEDIA_SESSION_FAVOURITE_LIST) favouriteList: Array<Song> = new Array()
    @State curTabIndex: number = 0
    private playlistScroller = new Scroller()
    @Link playingIndex: number
    @Link isShow: boolean
    onAction: (song: Song) => void = () => {
    }
    onDelete: (song: Song) => void = () => {
    }
    onUnFavourite: (song: Song) => void = () => {
    }

    @Builder
    TabTitle(title: string, index: number) {
        Text(title).fontSize(UIConfig.FONT_SUB_TITLE)
            .fontColor(this.curTabIndex == index ? this.theme.colorPrimary : "#cc3e3e3e")
    }

    build() {
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
                                            this.onAction(song)
                                        },
                                        onDelete: (song: Song) => {
                                            this.onDelete(song)
                                        }
                                    })
                                }
                            } else {
                                ListItem() {
                                    PlaylistItemView({
                                        data: song,
                                        isHighLight: false,
                                        onAction: (song: Song) => {
                                            this.onAction(song)
                                        },
                                        onDelete: (song: Song) => {
                                            this.onDelete(song)
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
                        ForEach(this.favouriteList, (song: Song) => {
                            ListItem() {
                                FavouriteItemView({ data: song, isHighLight: false,
                                    onAction: (song: Song) => {
                                        this.onAction(song)
                                    },
                                    onFavourite: (song: Song) => {
                                        this.onUnFavourite(song)
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
                this.isShow = false
            }
        })
    }
}