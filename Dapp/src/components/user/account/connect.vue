<template>
  <div>
    <!-- <UButton color="white" class="px-4 py-2" @click="clickHandler">
      <template #leading>
        <img :src="url" class="h-12 w-12 mr-2" />
      </template>
      <span>{{ connectState ? "create" : "connect" }}</span>
    </UButton> -->
    connect
  </div>
</template>

<script setup lang="ts">
import { AptosClient, wallets } from "@/config";
import { WalletCore } from "@aptos-labs/wallet-adapter-core";
import { StorageUtil } from "@/utils/storageUtil";

const walletCore = new WalletCore(wallets);
const connectState = ref(false);
const name = wallets[0].name;

onBeforeMount(() => {
  const addr = StorageUtil.getItem("addr");
  connectState.value = addr ? true : false;
});

const clickHandler = async () => {
  if (connectState) {
    console.log("create");
  } else {
    await walletCore.connect(name);
    StorageUtil.setItem("addr", walletCore.account?.address);
  }
};

walletCore.on("connect", () => {
  console.log(walletCore.wallet?.name, walletCore.account?.address, "success");
});

const disconnectHandler = () => {
  walletCore.disconnect();
  console.log("disconnected");
};
const url = wallets[0].icon;
</script>
