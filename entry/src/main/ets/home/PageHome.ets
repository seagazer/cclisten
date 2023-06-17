import { navigationTo } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'
import { ExtImage } from '../view/ExtImage'
import { Logger } from '../extensions/Logger'
import { FileScanner } from '../medialibrary/FileScanner'
import { ListItemView } from '../view/ListItemView'
import router from '@ohos.router'
import { Song } from '../bean/Song'
import {
    APP_THEME,
    LiveData,
    MEDIA_SESSION_CURRENT_SONG,
    MEDIA_SESSION_FILE_LIST,
} from '../extensions/LiveData'
import { MediaSession } from '../player/MediaSession'
import { DEFAULT_THEME, Theme } from '../theme/Theme'

const TAG = "[PageHome]"

@Entry
@Component
struct PageHome {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @State songList: Array<Song> = new Array()
    @State currentPosition: number = 0
    @State duration: number = 100

    aboutToAppear() {
        router.clear()
        FileScanner.scanMediaLibrary(getContext(this)).then((result) => {
            Logger.d(TAG, "scan audio files= " + JSON.stringify(result))
            this.songList = result
            LiveData.syncLiveData(MEDIA_SESSION_FILE_LIST, this.songList)
        })
    }

    @Builder
    TitleBar() {
        Row() {
            Text("Listen")
                .fontColor(this.theme.colorPrimary)
                .fontSize(36)
                .fontWeight(800)

            // ExtImage({
            //     src: $r("app.media.baseline_more_vert_24"),
            //     widthSize: 56,
            //     heightSize: 56,
            //     imageFit: ImageFit.Contain,
            //     paddingSize: 8,
            //     borderOp: { radius: 40 }
            // })

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
                    LiveData.syncLiveData(MEDIA_SESSION_CURRENT_SONG, song)
                    MediaSession.get().playSong(song)
                    navigationTo(PageRouter.PAGE_PLAY)
                })
            })
        }
        .width("100%")
        .layoutWeight(1)
        .margin({ top: 16 })
        .padding({ left: 16, right: 16, bottom: 16 })
    }

    build() {
        Column() {
            this.TitleBar()

            Text("本地音乐").padding({ left: 16 })
                .width("100%")

            if (this.songList.length > 0) {
                this.MusicList()
            } else {
                this.EmptyView()
            }
        }
        .width("100%")
        .height("100%")
        .alignItems(HorizontalAlign.Start)
    }
}