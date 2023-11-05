import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'
import { Logger } from './Logger'

const TAG = "[DbHelper]"

export interface IDbAction<T> {
    insert(t: T): Promise<number>

    insertArray(t: Array<T>): Promise<number>

    update(matchKey: string, data: T): Promise<number>

    delete(matchKey: string, data: T): Promise<number>

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
    private primaryKey: string = "id"

    public setPrimaryKey(primaryKey: string) {
        this.primaryKey = primaryKey
    }

    public addColumn(key: string, valueType: ColumnValueType) {
        this.keyMap.set(key, valueType)
    }

    public async create(context: common.Context, tableName: string, level: relationalStore.SecurityLevel = relationalStore.SecurityLevel.S1) {
        try {
            if (this.keyMap.size <= 0) {
                Logger.e(TAG, "The column of table is null, create table failed!")
                return null
            }
            this.tableName = tableName
            this.db = await relationalStore.getRdbStore(context,
                {
                    name: tableName + '.db',
                    securityLevel: level
                })
            Logger.d(TAG, "create db= " + this.db)
            let keyMapSql = ""
            let i = 0
            for (let key of this.keyMap.keys()) {
                let value = this.keyMap.get(key)
                if (i != this.keyMap.size - 1) {
                    if (key === this.primaryKey) {
                        keyMapSql += key + " " + value + " PRIMARY KEY, "
                    } else {
                        keyMapSql += key + " " + value + ", "
                    }
                } else {
                    if (key === this.primaryKey) {
                        keyMapSql += key + " " + value + " PRIMARY KEY"
                    } else {
                        keyMapSql += key + " " + value
                    }
                }
                i++
            }
            let sql = ""
            if (this.keyMap.get(this.primaryKey)) {
                sql = "CREATE TABLE IF NOT EXISTS " + tableName + " ( " + keyMapSql + ")"
            } else {
                sql = "CREATE TABLE IF NOT EXISTS " + tableName + " (id INTEGER PRIMARY KEY AUTOINCREMENT, " + keyMapSql + ")"
            }
            Logger.d(TAG, "sql= " + sql)
            await this.db.executeSql(sql)
            Logger.d(TAG, "execute sql success")
            return this.db
        } catch (err) {
            Logger.e(TAG, "create db error= " + JSON.stringify(err))
            return null
        }
    }

    public async insert(data: T) {
        if (!this.db) {
            Logger.w(TAG, "The RdbStore is null!")
            return -1
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
            return -1
        }
        try {
            let valueList = []
            list.forEach((data) => {
                let value = {}
                this.keyMap.forEach((_, key) => {
                    value[key] = data[key]
                })
                Logger.d(TAG, "insert data= " + JSON.stringify(value))
                valueList.push(value)
            })
            let resultCode = await this.db.batchInsert(this.tableName, valueList)
            return resultCode
        } catch (err) {
            Logger.e(TAG, "insert error= " + JSON.stringify(err))
            return -1
        }
    }

    public async delete(matchKey: string, data: T) {
        if (!this.db) {
            Logger.w(TAG, "The RdbStore is null!")
            return -1
        }
        try {
            let predicates = new relationalStore.RdbPredicates(this.tableName)
            predicates.equalTo(matchKey, data[matchKey])
            Logger.d(TAG, "delete data= " + JSON.stringify(data))
            let resultCode = await this.db.delete(predicates)
            return resultCode
        } catch (err) {
            Logger.e(TAG, "delete error= " + JSON.stringify(err))
            return -1
        }
    }

    public async update(matchKey: string, data: T) {
        if (!this.db) {
            Logger.w(TAG, "The RdbStore is null!")
            return -1
        }
        try {
            const value = {}
            this.keyMap.forEach((_, key) => {
                value[key] = data[key]
            })
            const predicates = new relationalStore.RdbPredicates(this.tableName)
            predicates.equalTo(matchKey, data[matchKey])
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
                let t = this.readRow(cursor)
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

    private readRow(cursor: relationalStore.ResultSet) {
        let result = {}
        for (let key of this.keyMap.keys()) {
            let valueType = this.keyMap.get(key)
            switch (valueType) {
                case "TEXT":
                    let stringValue = cursor.getString(cursor.getColumnIndex(key))
                    result[key] = stringValue
                    break
                case "INTEGER":
                    let intValue = cursor.getLong(cursor.getColumnIndex(key))
                    result[key] = intValue
                    break
            }
        }
        return result as T
    }
}
