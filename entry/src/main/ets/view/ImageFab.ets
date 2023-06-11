import { dimColor } from '../extensions/Extensions'

@Component
export struct ImageFab {
    color: number | string = "#ffe2e2e2"
    dimColor: number
    onAction: (event: ClickEvent) => void

    aboutToAppear() {
        this.dimColor = dimColor(this.color, 0.95)
    }

    @Styles normal(){
        .backgroundColor(this.color)
        .border({ radius: 200 })
        .shadow({ radius: 12, color: "#cc3a3a3a", offsetY: 4 })
    }

    @Styles press(){
        .backgroundColor(this.dimColor)
        .border({ radius: 200 })
        .shadow({ radius: 8, color: "#ff3a3a3a", offsetY: 4 })
    }

    build() {
        Image($r("app.media.baseline_play_arrow_24"))
            .width(48)
            .padding(8)
            .aspectRatio(1)
            .stateStyles({
                normal: this.normal,
                pressed: this.press
            })
            .onClick((event) => {
                this.onAction?.(event)
            })
    }
}