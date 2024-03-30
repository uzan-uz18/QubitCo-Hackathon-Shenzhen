export class StorageUtil {
    // Check if running in the browser environment
    private static isClientSide(): boolean {
        return typeof window !== "undefined";
    }

    // Store an item in the storage
    static setItem(key: string, value: any): void {
        if (StorageUtil.isClientSide()) {
            localStorage.setItem(key, JSON.stringify(value));
        }
    }

    // Retrieve an item from the storage
    static getItem<T>(key: string): T | null {
        if (StorageUtil.isClientSide()) {
            const value = localStorage.getItem(key);
            return value ? (JSON.parse(value) as T) : null;
        }
        return null;
    }

    // Remove an item from the storage
    static removeItem(key: string): void {
        if (StorageUtil.isClientSide()) {
            localStorage.removeItem(key);
        }
    }

    // Clear all items from the storage
    static clear(): void {
        if (StorageUtil.isClientSide()) {
            localStorage.clear();
        }
    }
}
