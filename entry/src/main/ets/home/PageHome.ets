import { navigationTo } from '../extensions/Extensions'
import { PageRouter } from '../extensions/PageRouter'
import { ImageFab } from '../view/ImageFab'

@Entry
@Component
struct PageHome {
    @Builder
    BottomBar() {
        Row() {
            Image($r("app.media.ic_cover_default"))
                .height("100%")
                .aspectRatio(1)
                .padding(8)
                .backgroundColor("#ffd7afaf")

            Column() {
                Text("可能")
                    .textAlign(TextAlign.Start)
                    .fontSize(18)
                    .padding({ top: 8 })
                    .width("100%")
                Blank()
                Progress({
                    value: 100,
                    total: 100
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

    @State mockData: Array<number> = []

    aboutToAppear() {
        for (let i = 0;i < 20; i++) {
            this.mockData.push(i)
        }
    }

    build() {
        Column() {
            Row() {
                Text("Listen").fontSize(36).fontWeight(800)

                Image($r("app.media.baseline_menu_24"))
                    .width(40).height(40)
            }.width("100%").justifyContent(FlexAlign.SpaceBetween)
            .padding(16)

            Stack() {
                Column() {

                    List() {
                        ForEach(this.mockData, (data, index) => {
                            ListItem() {
                                Row() {
                                    Image($r("app.media.icon"))
                                        .width(40)
                                        .height(40)

                                    Text("" + index)

                                    Column() {
                                        Text("可能").fontSize(18)
                                        Text("程响").fontSize(14).fontColor("#cccccc")
                                    }
                                    .padding({ left: 16 })
                                    .layoutWeight(1)
                                    .justifyContent(FlexAlign.SpaceBetween)
                                    .alignItems(HorizontalAlign.Start)

                                    Image($r("app.media.baseline_more_vert_24"))
                                        .width(40)
                                        .height(40)
                                        .colorBlend("#cccc")
                                }
                                .width("100%")
                                .height(56)
                            }
                        })
                    }
                    .layoutWeight(1)
                    .margin({ top: 16 })
                    .padding({ left: 16, right: 16 })
                }
                .width("100%")
                .height("100%")

                // Column() {
                //     Image($r("app.media.ic_empty"))
                //         .width(100)
                //         .height(100)
                //     Text("暂无歌曲").fontSize(16).margin({ top: 8 })
                // }
                // .width("100%").height("100%")
                // .justifyContent(FlexAlign.Center)
                // .backgroundColor("#ffffff")
            }
            .width("100%")
            .layoutWeight(1)


            this.BottomBar()
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(HorizontalAlign.Start)
    }
}