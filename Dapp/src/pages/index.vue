<template>
  <div class="flex flex-col gap-y-20">
    <div class="flex items-center justify-between">
      <UserHello :addr="addrString" />
      <UButton
        v-if="connectState"
        label="Create Dao"
        variant="outline"
        to="/dao/create"
      />
    </div>
    <UDivider class="shadow" />
    <Dao />
  </div>
</template>

<script setup lang="ts">
import { shortenString } from "@/utils/tools"
const connectState = useState("connectState");

const connectStatus = computed(
  () => connectState.value || StorageUtil.getItem("addr")
);

const addrString = computed(() => {
  return connectStatus.value
    ? shortenString(StorageUtil.getItem("addr") as string, 4, 3)
    : "0x00";
});
</script>
