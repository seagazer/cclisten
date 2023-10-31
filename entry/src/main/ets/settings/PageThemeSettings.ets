@Entry
@Component
struct PageThemeSettings {
    @State message: string = '主题设置'

    build() {
        Row() {
            Column() {
                Text(this.message)
                    .fontSize(50)
                    .fontWeight(FontWeight.Bold)
            }
            .width('100%')
        }
        .height('100%')
    }
}