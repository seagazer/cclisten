import { Logger } from '../extensions/Logger';
import { Song } from '../bean/Song';
import { MediaSession } from '../player/MediaSession';
import router from '@ohos.router';
import { PagePlayer } from './PagePlayer';
import { APP_THEME } from '../extensions/LiveData';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { MethodInvoker } from '../extensions/MethodInvoker';
import { PageMediaLibrary } from './PageMediaLibrary';

const TAG = "[PageHome]"


@Entry
@Component
struct PageHome {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @State animAlpha: number = 1
    @State lyricLine: string = " "
    @State isShowLyric: boolean = false
    @State currentTabId: number = 0
    private mediaSession: MediaSession = MediaSession.get()
    private pagePlayerInvoker = MethodInvoker.create()

    aboutToAppear() {
        router.clear()
        // @ts-ignore
        let song = router.getParams().data
        if (song) {
            Logger.d(TAG, "play from router= " + JSON.stringify(song))
            this.mediaSession.playSong(song as Song)
        }
    }

    onBackPress() {
        if (this.pagePlayerInvoker.invoke("backPress")) {
            return true
        }
    }

    private tabController = new TabsController()

    @Builder
    TabMore() {
        Column() {
            Row() {
                Image($r("app.media.baseline_arrow_back_ios_24")).width(32).height(32)
                Text("关于").fontSize(16).margin({ left: 16 })
            }

            Row() {
                Image($r("app.media.baseline_arrow_back_ios_24")).width(32).height(32)
                Text("关于").fontSize(16).margin({ left: 16 })
            }.margin({ top: 4 })
        }
    }

    @Builder
    Tab(id: number, title: string) {
        Text(title)
            .fontSize(18)
            .fontColor(this.currentTabId === id ? this.theme.colorPrimary : "#000000")
            .fontWeight(this.currentTabId === id ? 600 : 400)
            .scale({ x: this.currentTabId === id ? 1.15 : 1, y: this.currentTabId === id ? 1.15 : 1 })
            .animation({
                duration: 250
            })
    }

    build() {
        Column() {
            Tabs({ controller: this.tabController }) {
                TabContent() {
                    PagePlayer({ invoker: this.pagePlayerInvoker })
                }
                .tabBar(this.Tab(0, "首页"))

                TabContent() {
                    PageMediaLibrary()
                }.tabBar(this.Tab(1, "媒体库"))

                TabContent() {
                    this.TabMore()
                }.tabBar(this.Tab(2, "更多"))
            }
            .barWidth(300)
            .barMode(BarMode.Fixed)
            .animationDuration(200)
            .onChange((index: number) => {
                this.currentTabId = index
            })
        }
        .width('100%')
        .height('100%')
    }
}