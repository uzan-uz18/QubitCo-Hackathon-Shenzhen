<template>
  <UCard
    :ui="{
      divide: '',
      ring: '',
      shadow: '',
      background: 'bg-transparent dark:bg-transparent',
    }"
  >
    <template #header>
      <span class="text-2xl font-bold">{{ title }}</span>
    </template>
    <div>
      <DaoList :data="title === 'My Daos' ? data : staticData" />
    </div>
  </UCard>
</template>
<script setup lang="ts">
import { getDaos } from "@/dataset/data";
import { data as staticData } from "@/dataset/dao";

type Props = {
  title?: string;
};
const props = withDefaults(defineProps<Props>(), {
  title: "Daos",
});

const { data, pending } = useAsyncData("getDao", async () => {
  const res = await getDaos();
  const result = {
    ...res[0].data,
    description:
      "A decentralized organization dedicated to stabilizing the value of its stablecoin, DAI, through autonomous interest rate adjustments based on market dynamics.",
    icon: "/images/city-of-the-future.webp",
  };
  StorageUtil.setItem("dao", result);
  return [result];
});
</script>
