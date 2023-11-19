import { Logger } from '../extensions/Logger'

const TAG = "[MethodInvoker]"

/**
 * Author: seagazer
 * Date: 2023/8/27
 */
export class MethodInvoker {
    private methodTable = new Map<string, Function>()
    private caller: any
    private static sInstance: MethodInvoker = null

    private constructor() {
    }

    public static create(): MethodInvoker {
        if (!this.sInstance) {
            this.sInstance = new MethodInvoker()
        }
        return this.sInstance
    }

    registerContext(context: any) {
        this.caller = context
    }

    registerMethod(method: Function) {
        this.methodTable.set(method.name, method)
    }

    invoke(methodName: string, args?: any) {
        let method = this.methodTable.get(methodName)
        if (!method) {
            Logger.w(TAG, "The #" + methodName + " is not registered!")
            return
        }
        if (!this.caller) {
            Logger.w(TAG, "The caller context is not registered!")
            return
        }
        return method.apply(this.caller, args)
    }
}