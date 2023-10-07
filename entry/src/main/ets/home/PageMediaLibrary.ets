import { Song } from '../bean/Song'
import { UIConfig } from '../config/UIConfig'
import { APP_THEME } from '../extensions/LiveData'
import { Logger } from '../extensions/Logger'
import { FileScanner } from '../extensions/FileScanner'
import { MediaSession } from '../player/MediaSession'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { ListItemView } from '../view/ListItemView'

const TAG = "[HomeLibrary]"

@Component
export struct PageMediaLibrary {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @State songList: Array<Song> = new Array()
    @State currentPosition: number = 0
    @State duration: number = 100
    @State isLoading: boolean = true
    onClickEvent: () => void

    aboutToAppear() {
        FileScanner.scanMediaLibrary(getContext(this)).then((result) => {
            Logger.d(TAG, "scan audio files= " + JSON.stringify(result))
            this.songList = result
            this.isLoading = false
        })
    }

    @Builder
    EmptyView() {
        Column() {
            Image($r("app.media.ic_empty"))
                .width(100)
                .height(100)
            Text("暂无歌曲").fontSize(UIConfig.FONT_SUB_TITLE).margin({ top: 8 })
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
                    MediaSession.get().playSong(song)
                    this.onClickEvent?.()
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
            if (this.isLoading) {
                Column() {
                    LoadingProgress()
                        .width(48).height(48).color(this.theme.colorPrimary)

                    Text("正在扫描").fontSize(UIConfig.FONT_SUB_TITLE).fontColor(this.theme.colorPrimary)
                        .margin({ top: 16 })
                }
                .width("100%")
                .layoutWeight(1)
                .justifyContent(FlexAlign.Center)
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
        .padding(16)
    }
}