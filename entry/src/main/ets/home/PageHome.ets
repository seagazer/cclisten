import { Logger } from '../extensions/Logger';
import { Song } from '../bean/Song';
import { MediaSession } from '../player/MediaSession';
import router from '@ohos.router';
import { PagePlayer } from './PagePlayer';
import { APP_THEME, LiveData, MEDIA_SESSION_CURRENT_SONG } from '../extensions/LiveData';
import { DEFAULT_THEME, Theme } from '../theme/Theme';
import { MethodInvoker } from '../base/MethodInvoker';
import { UIConfig } from '../config/UIConfig';
// import { PageMore } from './PageMore';

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
    @State isNotPlayed: boolean = true

    aboutToAppear() {
        router.clear()
        let param = router.getParams()
        if (param) {
            let song = param as Song
            if (song) {
                Logger.d(TAG, "play from router= " + JSON.stringify(song))
                this.mediaSession.playSong(song as Song)
                LiveData.setValue(MEDIA_SESSION_CURRENT_SONG, song)
                this.isNotPlayed = false
            }
        }
    }

    onBackPress() {
        if (this.pagePlayerInvoker.invoke("backPress")) {
            return true
        }
        return false
    }

    @Builder
    Tab(id: number, title: string) {
        Text(title)
            .fontSize(UIConfig.FONT_SUB_TITLE)
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
                    PagePlayer({ invoker: this.pagePlayerInvoker, isNotPlayed: this.isNotPlayed })
                }
                .tabBar(this.Tab(0, "首页"))

                // TabContent() {
                //     PageMore()
                // }.tabBar(this.Tab(2, "更多"))
            }
            .barWidth(300)
            .barMode(BarMode.Fixed)
            .animationDuration(300)
            .backgroundColor(Theme.APP_BACKGROUND_COLOR)
            .onChange((index: number) => {
                this.currentTabId = index
            })
        }
        .width('100%')
        .height('100%')
    }
}