import { Logger } from '../extensions/Logger';
import { Song } from '../bean/Song';
import { MediaSession } from '../player/MediaSession';
import router from '@ohos.router';
import { PagePlayer } from './PagePlayer';
import { APP_THEME } from '../extensions/LiveData';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { MethodInvoker } from '../extensions/MethodInvoker';
import { PageMediaLibrary } from './PageMediaLibrary';
import { PageMore } from './PageMore';

const TAG = "[PageHome]"


@Entry
@Component
struct PageHome {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @State animAlpha: number = 1
    @State lyricLine: string = " "
    @State isShowLyric: boolean = false
    @State currentTabId: number = 0
    private tabController = new TabsController()
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

    @Builder
    Tab(id: number, title: string) {
        Text(title)
            .fontSize(18)
            .fontColor(this.currentTabId === id ? this.theme.colorPrimary : "#000000")
            .scale({ x: this.currentTabId === id ? 1.15 : 1, y: this.currentTabId === id ? 1.15 : 1 })
            .animation({
                duration: 300
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
                    PageMediaLibrary({ onClickEvent: () => {
                        this.tabController.changeIndex(0)
                    } })
                }.tabBar(this.Tab(1, "媒体库"))

                TabContent() {
                    PageMore()
                }.tabBar(this.Tab(2, "更多"))
            }
            .barWidth(300)
            .barMode(BarMode.Fixed)
            .animationDuration(300)
            .onChange((index: number) => {
                this.currentTabId = index
            })
        }
        .width('100%')
        .height('100%')
    }
}