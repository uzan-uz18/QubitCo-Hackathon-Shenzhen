export class StorageUtil {
    // Store an item in the storage
    static setItem(key: string, value: any): void {
        localStorage.setItem(key, JSON.stringify(value));
    }

    // Retrieve an item from the storage
    static getItem<T>(key: string): T | null {
        const value = localStorage.getItem(key);
        return value ? (JSON.parse(value) as T) : null;
    }

    // Remove an item from the storage
    static removeItem(key: string): void {
        localStorage.removeItem(key);
    }

    // Clear all items from the storage
    static clear(): void {
        localStorage.clear();
    }
}
