import { UIConfig } from '../config/UIConfig'
import { dimColor } from '../extensions/Extensions'

@Component
export struct ImageFab {
    color: number | string = "#ffe2e2e2"
    dimColor: number
    onAction: (event: ClickEvent) => void

    aboutToAppear() {
        this.dimColor = dimColor(this.color, 0.95)
    }

    @Styles
    normal(){
        .backgroundColor(this.color)
        .border({ radius: UIConfig.DIMENSION_CIRCLE })
        .shadow({
            radius: UIConfig.DIMENSION_NORMAL_SHADOW,
            color: "#cc3a3a3a",
            offsetY: UIConfig.DIMENSION_OFFSET_SHADOW
        })
    }

    @Styles
    press(){
        .backgroundColor(this.dimColor)
        .border({ radius: UIConfig.DIMENSION_CIRCLE })
        .shadow({
            radius: UIConfig.DIMENSION_PRESS_SHADOW,
            color: "#ff3a3a3a",
            offsetY: UIConfig.DIMENSION_OFFSET_SHADOW
        })
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