import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { Logger } from './Logger'

const TAG = "[DbHelper]"

export interface IDbAction<T> {
    insert(t: T): Promise<number>

    insertArray(t: Array<T>): Promise<number>

    update(t: T, key: string): Promise<number>

    delete(t: T, key: string): Promise<number>

    query(): Promise<Array<T>>
}

export type ColumnValueType = "TEXT" | "INTEGER"

/**
 * Author: seagazer
 * Date: 2023/9/17
 */
export class DbHelper<T> implements IDbAction<T> {
    private db: relationalStore.RdbStore = null
    private keyMap = new Map<string, ColumnValueType>()
    private tableName: string

    public addTableColumn(key: string, valueType: ColumnValueType) {
        this.keyMap.set(key, valueType)
    }

    public async createTable(context: common.Context, tableName: string) {
        try {
            if (this.keyMap.size <= 0) {
                Logger.e(TAG, "The column of table is null, create table failed!")
                return -1
            }
            this.tableName = tableName
            this.db = await relationalStore.getRdbStore(context,
                {
                    name: tableName + '.db',
                    securityLevel: relationalStore.SecurityLevel.S1
                })
            Logger.d(TAG, "create db= " + this.db)
            let keyMapSql = ""
            let i = 0
            for (let key of this.keyMap.keys()) {
                let value = this.keyMap.get(key)
                if (i != this.keyMap.size - 1) {
                    keyMapSql += key + " " + value + ", "
                } else {
                    keyMapSql += key + " " + value
                }
                i++
            }
            let sql = "CREATE TABLE IF NOT EXISTS " + tableName + " (id INTEGER PRIMARY KEY AUTOINCREMENT, " + keyMapSql + ")"
            Logger.d(TAG, "sql= " + sql)
            await this.db.executeSql(sql)
            Logger.d(TAG, "execute sql success")
            return 1
        } catch (err) {
            return -1
        }
    }

    public async insert(data: T) {
        if (!this.db) {
            Logger.w(TAG, "The RdbStore is null!")
            return
        }
        try {
            let value = {}
            this.keyMap.forEach((_, key) => {
                value[key] = data[key]
            })
            Logger.d(TAG, "insert data= " + JSON.stringify(value))
            let resultCode = await this.db.insert(this.tableName, value)
            return resultCode
        } catch (err) {
            Logger.e(TAG, "insert error= " + JSON.stringify(err))
            return -1
        }
    }

    public async insertArray(list: Array<T>) {
        if (!this.db) {
            Logger.w(TAG, "The RdbStore is null!")
            return
        }
        try {
            let values = []
            list.forEach((t) => {
                let value = {}
                this.keyMap.forEach((_, key) => {
                    value[key] = t[key]
                })
                Logger.d(TAG, "insert data= " + JSON.stringify(value))
                values.push(value)
            })
            let resultCode = await this.db.batchInsert(this.tableName, values)
            return resultCode
        } catch (err) {
            Logger.e(TAG, "insert array error= " + JSON.stringify(err))
            return -1
        }
    }

    public async delete(data: T, key: string) {
        if (!this.db) {
            Logger.w(TAG, "The RdbStore is null!")
            return
        }
        try {
            let predicates = new relationalStore.RdbPredicates(this.tableName)
            predicates.equalTo(key, data[key])
            Logger.d(TAG, "delete data= " + JSON.stringify(data))
            let resultCode = await this.db.delete(predicates)
            return resultCode
        } catch (err) {
            Logger.e(TAG, "delete error= " + JSON.stringify(err))
            return -1
        }
    }

    public async update(data: T, key: string) {
        if (!this.db) {
            Logger.w(TAG, "The RdbStore is null!")
            return
        }
        try {
            const value = {}
            this.keyMap.forEach((_, key) => {
                value[key] = data[key]
            })
            const predicates = new relationalStore.RdbPredicates(this.tableName)
            predicates.equalTo(key, data[key])
            Logger.d(TAG, "update data= " + JSON.stringify(value))
            let resultCode = await this.db.update(value, predicates)
            return resultCode
        } catch (err) {
            Logger.e(TAG, "update error= " + JSON.stringify(err))
            return -1
        }
    }

    public async query() {
        if (!this.db) {
            Logger.w(TAG, "The RdbStore is null!")
            return
        }
        try {
            let predicates = new relationalStore.RdbPredicates(this.tableName)
            const columns = []
            this.keyMap.forEach((_, key) => {
                columns.push(key)
            })
            let cursor = await this.db.query(predicates, columns)
            let result: Array<T> = []
            cursor.goToFirstRow()
            while (!cursor.isEnded) {
                let t = this.readProps(cursor)
                result.push(t)
                cursor.goToNextRow()
            }
            cursor.close()
            Logger.d(TAG, "query list= " + JSON.stringify(result))
            return result
        } catch (err) {
            Logger.e(TAG, "query error= " + JSON.stringify(err))
            return new Array<T>()
        }
    }

    private readProps(cursor: relationalStore.ResultSet) {
        let result = {}
        for (let key of this.keyMap.keys()) {
            let valueType = this.keyMap.get(key)
            switch (valueType) {
                case "TEXT":
                    let tv = cursor.getString(cursor.getColumnIndex(key))
                    result[key] = tv
                    break
                case "INTEGER":
                    let iv = cursor.getLong(cursor.getColumnIndex(key))
                    result[key] = iv
                    break
            }
        }
        return result as T
    }
}
