import { navigationTo } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'
import { ExtImage } from '../view/ExtImage'
import { Logger } from '../extensions/Logger'
import { FileScanner } from '../medialibrary/FileScanner'
import { Song } from '../bean/Song'
import { MusicListItem } from '../view/MusicListItem'

const TAG = "PageHome"

@Entry
@Component
struct PageHome {
    @State songList: Array<Song> = new Array
    @State currentSong: Song = null
    @State currentPosition: number = 0
    @State duration: number = 100

    @Builder
    BottomBar() {
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

            // ImageFab()
            Image($r("app.media.baseline_play_circle_24"))
                .height("100%")
                .aspectRatio(1)
        }
        .width("100%")
        .height(64)
        .shadow({ radius: 6, color: "#cccc" })
        .onClick(() => {
            navigationTo(PageRouter.PAGE_PLAY)
        })
    }

    aboutToAppear() {
        FileScanner.scan(getContext(this).filesDir).then((result) => {
            Logger.d(TAG, "scan mp3 files= " + JSON.stringify(result))
            result.forEach((path) => {
                let split = path.split("/")
                let file = split[split.length-1].split(".")
                let title = file[0]
                this.songList.push(new Song(path, title))
            })
        })
    }

    @Builder
    TitleBar() {
        Row() {
            Text("Listen").fontSize(36).fontWeight(800)

            ExtImage({
                src: $r("app.media.baseline_menu_24"),
                widthSize: 56,
                heightSize: 56,
                imageFit: ImageFit.Contain,
                paddingSize: 8,
                borderOp: { radius: 40 }
            })

        }.width("100%").justifyContent(FlexAlign.SpaceBetween)
        .padding(16)
    }

    build() {
        Column() {
            this.TitleBar()

            Text("本地音乐").padding({ left: 16 })
                .width("100%")

            if (this.songList.length > 0) {
                Column() {
                    List() {
                        ForEach(this.songList, (song: Song, index) => {
                            ListItem() {
                                MusicListItem({ data: song, index: index + 1,
                                    onItemClick: (song) => {
                                        this.currentSong = song
                                        // todo play song
                                    }
                                })
                            }
                        })
                    }
                    .layoutWeight(1)
                    .margin({ top: 16 })
                    .padding({ left: 16, right: 16, bottom: 16 })
                }
                .width("100%")
                .layoutWeight(1)
            } else {
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

            this.BottomBar()
        }
        .width("100%")
        .height("100%")
        .alignItems(HorizontalAlign.Start)
    }
}