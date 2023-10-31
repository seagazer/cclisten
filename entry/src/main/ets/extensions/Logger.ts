import hilog from '@ohos.hilog'

const domain = 0x101

/**
 * Author: seagazer
 * Date: 2023/4/18
 */
export class Logger {
    private static DEBUG = true
    private static APP = "<Listen>"

    static setDebugger(debug: boolean) {
        this.DEBUG = debug
    }

    static setAppName(name: string) {
        this.APP = "<" + name + "> "
    }

    static d(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.debug(domain, this.APP + tag, message)
    }

    static w(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.warn(domain, this.APP + tag, message)
    }

    static i(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.info(domain, this.APP + tag, message)
    }

    static e(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.error(domain, this.APP + tag, message)
    }

    static f(tag: string, message: string) {
        if (!this.DEBUG) {
            return
        }
        hilog.fatal(domain, this.APP + tag, message)
    }
}