
import { AptosClient, wallets } from "@/config";
import { WalletCore } from "@aptos-labs/wallet-adapter-core";
import { StorageUtil } from "@/utils/storageUtil";

const connectState = ref(false);
const name = wallets[0].name;

const clickHandler = async () => {
    if (connectState) {
        console.log("create");
    } else {
        await walletCore.connect(name);
        StorageUtil.setItem("addr", walletCore.account?.address);
    }
};

// walletCore.on("connect", () => {
//     console.log(walletCore.wallet?.name, walletCore.account?.address, "success");
// });

const disconnectHandler = () => {
    walletCore.disconnect();
    console.log("disconnected");
};
const url = wallets[0].icon;

const connect = async () => {
    await walletCore.connect(name)
}

const disconnect = () => {
    walletCore.disconnect()
}

const walletCore = new WalletCore(wallets)

export { connect, disconnect, walletCore }