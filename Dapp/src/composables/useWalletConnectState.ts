import { ref } from 'vue';

// 初始化连接状态
const connectState = ref(false);

export function useWalletConnectState() {
    const setConnectState = (state: boolean) => {
        connectState.value = state;
        // 同步到localStorage
        StorageUtil.setItem('connectState', state);
    };

    const getConnectState = () => {
        // 从localStorage读取状态（兼容SSR场景）
        return connectState.value || StorageUtil.getItem('connectState');
    };

    return { setConnectState, getConnectState };
}
