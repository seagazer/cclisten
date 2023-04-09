import mediaQuery from '@ohos.mediaquery'

export default class BreakpointSystem {
    private currentBreakpoint: string = 'md'
    private smListener: mediaQuery.MediaQueryListener
    private mdListener: mediaQuery.MediaQueryListener
    private lgListener: mediaQuery.MediaQueryListener

    private updateCurrentBreakpoint(breakpoint: string) {
        if (this.currentBreakpoint !== breakpoint) {
            this.currentBreakpoint = breakpoint
            console.debug("------" + JSON.stringify(this.currentBreakpoint))
            AppStorage.Set<string>('currentBreakpoint', this.currentBreakpoint)
        }
    }

    private isBreakpointSM = (mediaQueryResult) => {
        if (mediaQueryResult.matches) {
            console.debug("------sm")
            this.updateCurrentBreakpoint('sm')
            AppStorage.Set<number>('fontSize', 14)
            AppStorage.Set<number>('coverMargin', 10)
        }
    }
    private isBreakpointMD = (mediaQueryResult) => {
        if (mediaQueryResult.matches) {
            console.debug("------md")
            this.updateCurrentBreakpoint('md')
            AppStorage.Set<number>('fontSize', 16)
            AppStorage.Set<number>('coverMargin', 30)
        }
    }
    private isBreakpointLG = (mediaQueryResult) => {
        if (mediaQueryResult.matches) {
            console.debug("------lg")
            this.updateCurrentBreakpoint('lg')
            AppStorage.Set<number>('fontSize', 18)
            AppStorage.Set<number>('coverMargin', 40)
        }
    }

    public register() {
        this.smListener = mediaQuery.matchMediaSync('(320vp<=width<520vp)')
        this.smListener.on('change', this.isBreakpointSM)
        this.mdListener = mediaQuery.matchMediaSync('(520vp<=width<840vp)')
        this.mdListener.on('change', this.isBreakpointMD)
        this.lgListener = mediaQuery.matchMediaSync('(840vp<=width)')
        this.lgListener.on('change', this.isBreakpointLG)
    }

    public unregister() {
        this.smListener.off('change', this.isBreakpointSM)
        this.mdListener.off('change', this.isBreakpointMD)
        this.lgListener.off('change', this.isBreakpointLG)
    }
}

@Entry
@Component
struct GridRowExample {
    private breakpointSystem: BreakpointSystem = new BreakpointSystem()
    @State currentBp: string = 'unknown'
    @StorageProp('currentBreakpoint') currentBreakpoint: string = 'sm'

    aboutToAppear() {
        this.breakpointSystem.register()
    }

    aboutToDisappear() {
        this.breakpointSystem.unregister()
    }

    build() {
        Column() {
            GridRow({
                columns: 2,
                //                breakpoints:
                //                {
                //                    value: ["400vp", "600vp", "800vp"],
                //                    reference: BreakpointsReference.WindowSize
                //                },
                direction: GridRowDirection.Row
            }) {
                GridCol({ span: { xs: 2, sm: 2, md: 1, lg: 1 } }) {
                    Column().width("100%").height("100%")
                }.backgroundColor(Color.Blue)

                if (this.currentBreakpoint !== 'sm') {
                    GridCol({ span: { xs: 2, sm: 2, md: 1, lg: 1 } }) {
                        Column().width("100%").height("100%")
                    }.backgroundColor(Color.Red)
                }
            }
            .width("100%").height("100%")
            //            .onBreakpointChange((breakpoint) => {
            //                this.currentBp = breakpoint
            //            })
        }.width('100%')
        .height("100%")
        .padding(16)
    }
}