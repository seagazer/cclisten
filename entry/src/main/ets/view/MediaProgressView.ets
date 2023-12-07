import { Logger } from '@seagazer/ccplayer'
import { Song } from '../bean/Song'
import { UIConfig } from '../config/UIConfig'
import { duration2text } from '../extensions/Extensions'
import { APP_THEME } from '../extensions/LiveData'
import { DEFAULT_THEME, Theme } from '../theme/Theme'

const TAG = "[MediaProgressView]"

@Component
export struct MediaProgressView {
    @StorageLink(APP_THEME) theme: Theme = DEFAULT_THEME
    @Link currentSong: Song
    @Link currentPosition: number
    onSeekChanged = (position: number) => {
    }

    build() {
        Row() {
            Text(duration2text(this.currentPosition))
                .fontSize(UIConfig.FONT_CONTENT)
                .fontColor(this.theme.colorPrimary)
            // slider
            Slider(
                {
                    style: SliderStyle.OutSet,
                    min: 0,
                    max: this.currentSong.duration,
                    value: this.currentPosition
                })
                .layoutWeight(1)
                .margin({ left: 8, right: 8 })
                .trackColor(this.theme.colorAction)
                .selectedColor(this.theme.colorPrimary)
                .onChange((value, mode) => {
                    if (mode == SliderChangeMode.End || mode == SliderChangeMode.Click) {
                        Logger.d(TAG, "seek to " + value + ", mode=" + mode + ", curPosition=" + this.currentPosition)
                        this.onSeekChanged(value)
                    }
                })

            Text(duration2text(this.currentSong.duration))
                .fontSize(UIConfig.FONT_CONTENT)
                .fontColor(this.theme.colorPrimary)
        }.width("100%")
    }
}