<template>
  <div class="flex flex-col gap-y-10">
    <DaoCard v-if="connectStatus" title="My Daos"/>
    <UDivider v-if="connectStatus" />
    <DaoCard title="Daos" />
  </div>
</template>

<script setup lang="ts">
const connectState = useState("connectState");

const connectStatus = computed(
  () => connectState.value || StorageUtil.getItem("addr")
);
</script>