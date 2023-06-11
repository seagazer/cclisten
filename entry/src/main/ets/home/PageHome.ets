import { navigationTo } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'
import { ExtImage } from '../view/ExtImage'
import { Logger } from '../extensions/Logger'
import { FileScanner } from '../medialibrary/FileScanner'
import { ListItemView } from './ListItemView'
import mediaLibrary from '@ohos.multimedia.mediaLibrary'
import router from '@ohos.router'

const TAG = "[PageHome]"

@Entry
@Component
struct PageHome {
    @State songList: Array<mediaLibrary.FileAsset> = new Array()
    @StorageLink("fileList") fileList: Array<mediaLibrary.FileAsset> = new Array()
    @StorageLink("currentSong") currentSong: mediaLibrary.FileAsset = null
    @State currentPosition: number = 0
    @State duration: number = 100
    @StorageLink("aaa") aaa: string = ""

    @Builder
    BottomBar() {
        Row() {
            Row() {
                Image($r("app.media.ic_cover_default"))
                    .height("100%")
                    .aspectRatio(1)
                    .padding(8)
                    .backgroundColor("#ffd7afaf")

                Column() {
                    Text(this.currentSong ? this.currentSong.title : "- -")
                        .textAlign(TextAlign.Start)
                        .fontSize(18)
                        .padding({ top: 8 })
                        .width("100%")
                    Blank()
                    Progress({
                        value: this.currentPosition,
                        total: this.duration
                    })
                }
                .padding({ left: 8 })
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.SpaceEvenly)
                .layoutWeight(1)
                .height("100%")
            }
            .layoutWeight(1)
            .height("100%")
            .onClick(() => {
                this.aaa = "xxxxxxxxxxxx"
                navigationTo(PageRouter.PAGE_PLAY)
            })

            Image($r("app.media.baseline_play_arrow_24"))
                .width(64)
                .height(64)
        }
        .width("100%")
        .height(64)
        .shadow({ radius: 6, color: "#cccc" })
    }

    aboutToAppear() {
        router.clear()
        FileScanner.scanMediaLibrary(getContext(this)).then((result) => {
            Logger.d(TAG, "scan audio files= " + JSON.stringify(result))
            this.songList = this.songList.concat(result)
            AppStorage.Set<Array<mediaLibrary.FileAsset>>("fileList", this.songList)
        })
    }

    @Builder
    TitleBar() {
        Row() {
            Text("Listen").fontSize(36).fontWeight(800)

            ExtImage({
                src: $r("app.media.baseline_more_vert_24"),
                widthSize: 56,
                heightSize: 56,
                imageFit: ImageFit.Contain,
                paddingSize: 8,
                borderOp: { radius: 40 }
            })

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
            ForEach(this.songList, (song: mediaLibrary.FileAsset, index) => {
                ListItem() {
                    ListItemView({ data: song, index: index + 1 })
                }.onClick(() => {
                    Logger.d(TAG, "param = " + song.title)
                    this.currentSong = song
                    AppStorage.Set<mediaLibrary.FileAsset>("currentSong", this.currentSong)
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

            // this.BottomBar()
        }

        .width("100%")
        .height("100%")
        .alignItems(HorizontalAlign.Start)
    }
}