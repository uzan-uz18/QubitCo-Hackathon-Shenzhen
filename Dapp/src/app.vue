<template>
  <div>
    <!-- <Button type="button"  @click="connectHandler">connect</Button>
    <button @click="disconnectHandler">disco</button> -->
    <NuxtLayout
      class="font-light min-h-screen bg-white text-black dark:bg-black dark:text-white transition-colors duration-200"
    >
      <NuxtPage />
      <UNotifications />
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
import { AptosClient, wallets } from "./config";
import { WalletCore } from "@aptos-labs/wallet-adapter-core";
const {
  public: { appName },
} = useRuntimeConfig();
useHead({
  titleTemplate(title) {
    return title ? `${title} - ${appName}` : appName;
  },
  link: [
    {
      rel: "icon",
      type: "image/x-icon",
      href: "/favicon.ico",
    },
    {
      rel: "icon",
      type: "image/png",
      sizes: "16x16",
      href: "/favicon-16x16.png",
    },
    {
      rel: "icon",
      type: "image/png",
      sizes: "32x32",
      href: "/favicon-32x32.png",
    },
    {
      rel: "apple-touch-icon",
      type: "image/png",
      sizes: "180x180",
      href: "/apple-touch-icon.png",
    },
    {
      rel: "manifest",
      href: "/site.webmanifest",
    },
  ],
});

const walletCore = new WalletCore(wallets);

walletCore.on("connect", () => {
  console.log(walletCore.wallet?.name, walletCore.account?.address, "success");
});

const connectHandler = () => {
  const name = wallets[0].name;
  console.log(name);
  walletCore.connect(name);
};

const disconnectHandler = () => {
  walletCore.disconnect();
  console.log("disconnected");
};
</script>
