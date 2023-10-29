import { navigationTo, toast } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'
import { Logger } from '../extensions/Logger'
import { FileScanner } from '../extensions/FileScanner'
import router from '@ohos.router'
import { Song } from '../bean/Song'
import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'
import { SelectItemView } from '../view/SelectItemView'
import { PlaylistManager } from '../playlist/PlaylistManager'
import { UIConfig } from '../config/UIConfig'

const TAG = "[PageFileList]"

@Entry
@Component
struct PageFileList {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @State songList: Array<Song> = new Array()
    @State currentPosition: number = 0
    @State isLoading: boolean = true
    @State isAllSelected: boolean = false
    private selectList: Array<Song> = new Array()
    private checkAllSelectedTimer = -1

    aboutToAppear() {
        router.clear()
    }

    @Builder
    TitleBar() {
        Row() {
            Text("本地文件")
                .fontColor(this.theme.colorPrimary)
                .fontSize(UIConfig.FONT_HEADER)
                .fontWeight(800)
        }.width("100%")
        .justifyContent(FlexAlign.SpaceBetween)
    }

    @Builder
    EmptyView() {
        Column() {
            Image($r("app.media.ic_empty"))
                .width(100)
                .height(100)
            Text("暂无歌曲")
                .fontSize(UIConfig.FONT_SUB_TITLE)
                .margin({ top: 8 })
        }
        .width("100%")
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor("#ffffff")
    }

    @Builder
    MusicList() {
        List() {
            ForEach(this.songList, (song: Song, _) => {
                ListItem() {
                    SelectItemView({ song: song, onItemSelectChanged: this.checkAllSelected })
                }
            })
        }
        .width("100%")
        .layoutWeight(1)
        .margin({ top: 16 })
        .scrollBar(BarState.Auto)
    }

    private checkAllSelected = () => {
        clearTimeout(this.checkAllSelectedTimer)
        this.checkAllSelectedTimer = setTimeout(() => {
            this.selectList = this.songList.filter((song) => {
                return song.isAdd == 1
            })
            if (this.selectList.length < this.songList.length) {
                this.isAllSelected = false
            } else {
                this.isAllSelected = true
            }
        }, 100)
    }

    @Styles
    pressedStyles() {
        .border({ radius: UIConfig.DIMENSION_CIRCLE })
        .backgroundColor(this.theme.colorAction)
    }

    @Styles
    normalStyles() {
        .border({ radius: UIConfig.DIMENSION_CIRCLE })
        .backgroundColor(null)
    }

    build() {
        RelativeContainer() {
            Column() {
                this.TitleBar()

                Row() {
                    Checkbox()
                        .width(24)
                        .height(24)
                        .selectedColor(this.theme.colorPrimary)
                        .select(this.isAllSelected)
                        .onChange((isChecked) => {
                            if (this.isAllSelected != isChecked) {
                                this.isAllSelected = isChecked
                                if (this.isAllSelected) {
                                    this.songList.forEach((song) => {
                                        song.isAdd = 1
                                    })
                                } else {
                                    this.songList.forEach((song) => {
                                        song.isAdd = 0
                                    })
                                }
                            }
                        })
                    Text(this.isAllSelected ? "取消全选" : "全选").padding({ left: 16 })
                        .width("100%")
                }
                .margin({ top: 16 })

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
                    .onAppear(() => {
                        FileScanner.scanMediaLibrary(getContext(this)).then((result) => {
                            Logger.d(TAG, "scan audio files= " + JSON.stringify(result))
                            this.songList = result
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
            .id("list")
            .width("100%")
            .height("100%")
            .padding(16)
            .alignItems(HorizontalAlign.Start)
            .alignRules({
                left: { anchor: "__container__", align: HorizontalAlign.Start },
                top: { anchor: "__container__", align: VerticalAlign.Top }
            })

            Image($r('app.media.baseline_play_circle_24'))
                .id("play")
                .width(64)
                .height(64)
                .padding(2)
                .stateStyles({
                    pressed: this.pressedStyles,
                    normal: this.normalStyles
                })
                .fillColor(this.theme.colorPrimary)
                .alignRules({
                    right: { anchor: "__container__", align: HorizontalAlign.End },
                    bottom: { anchor: "__container__", align: VerticalAlign.Bottom }
                })
                .margin({ right: 16, bottom: 48 })
                .onClick(() => {
                    Logger.d(TAG, "select playlist = " + JSON.stringify(this.selectList))
                    if (this.selectList.length > 0) {
                        PlaylistManager.get().addList(this.selectList)
                        navigationTo(PageRouter.PAGE_HOME, this.selectList[0]
                        )
                    } else {
                        toast("请选择至少一首歌曲")
                    }
                })
        }
        .width("100%")
        .height("100%")
    }
}