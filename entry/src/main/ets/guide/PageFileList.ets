import { navigationTo } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'
import { Logger } from '../extensions/Logger'
import { FileScanner } from '../medialibrary/FileScanner'
import { ListItemView } from '../view/ListItemView'
import router from '@ohos.router'
import { Song } from '../bean/Song'
import { APP_THEME, LiveData, MEDIA_SESSION_FILE_LIST, } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { PlaylistManager } from '../playlist/PlaylistManager'
import { PlaylistDb } from '../playlist/PlaylistDb'

const TAG = "[PageFileList]"

@Entry
@Component
struct PageFileList {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @State songList: Array<Song> = new Array()
    @State currentPosition: number = 0
    @State duration: number = 100
    @State isLoading: boolean = true

    aboutToAppear() {
        router.clear()
    }

    @Builder
    TitleBar() {
        Row() {
            Text("Listen")
                .fontColor(this.theme.colorPrimary)
                .fontSize(36)
                .fontWeight(800)
        }.width("100%").justifyContent(FlexAlign.SpaceBetween)
        .padding(16)
    }

    @Builder
    EmptyView() {
        Column() {
            Image($r("app.media.ic_empty"))
                .width(100)
                .height(100)
            Text("暂无歌曲").fontSize(16).margin({ top: 8 })
        }
        .width("100%")
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor("#ffffff")
    }

    @Builder
    MusicList() {
        List() {
            ForEach(this.songList, (song: Song, index) => {
                ListItem() {
                    ListItemView({ data: song, index: index + 1 })
                }.onClick(() => {
                    // MediaSession.get().playSong(song)
                    // todo save the playlist to db
                    PlaylistDb.get(getContext(this)).addSongList(this.songList)
                    navigationTo(PageRouter.PAGE_PLAY, {
                        data: song
                    })
                })
            })
        }
        .width("100%")
        .layoutWeight(1)
        .margin({ top: 16 })
        .padding({ left: 16, right: 16, bottom: 16 })
        .scrollBar(BarState.Auto)
    }

    build() {
        Column() {
            this.TitleBar()

            Text("本地音乐").padding({ left: 16 })
                .width("100%")

            if (this.isLoading) {
                Column() {
                    LoadingProgress()
                        .width(48).height(48).color(this.theme.colorPrimary)

                    Text("正在扫描").fontSize(18).fontColor(this.theme.colorPrimary)
                        .margin({ top: 16 })
                }
                .width("100%")
                .layoutWeight(1)
                .justifyContent(FlexAlign.Center)
                .onAppear(() => {
                    FileScanner.scanMediaLibrary(getContext(this)).then((result) => {
                        Logger.d(TAG, "scan audio files= " + JSON.stringify(result))
                        this.songList = result
                        LiveData.setValue(MEDIA_SESSION_FILE_LIST, this.songList)
                        PlaylistManager.get().addList(this.songList)
                        this.isLoading = false
                    })
                })
            } else {
                if (this.songList.length > 0) {
                    this.MusicList()
                } else {
                    this.EmptyView()
                }
            }
        }
        .width("100%")
        .height("100%")
        .alignItems(HorizontalAlign.Start)
    }
}