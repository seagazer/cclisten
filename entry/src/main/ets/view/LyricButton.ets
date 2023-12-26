import { SelectableImageButton } from './SelectableImageButton'

@Component
export struct LyricButton {
    @Link isShowLyric: boolean
    @Link isShowPlaylist: boolean
    @State lyricIcon: Resource = $r("app.media.ic_public_text")
    onAction: () => void = () => {
    }

    build() {
        SelectableImageButton({ image: this.lyricIcon, isSelected: this.isShowLyric })
            .onClick(() => {
                if (this.isShowLyric) {
                    this.isShowLyric = false
                    this.lyricIcon = $r('app.media.ic_public_text')
                } else {
                    if (this.isShowPlaylist) {
                        return
                    }
                    this.isShowLyric = true
                    this.onAction()
                    this.lyricIcon = $r('app.media.ic_public_text_filled')
                }
            })
    }
}