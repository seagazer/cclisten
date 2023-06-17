export function syncLiveData<T>(key: string, value: T) {
    AppStorage.Set<T>(key, value)
}