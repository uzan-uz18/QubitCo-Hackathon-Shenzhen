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
      <DaoList :data="title === 'My Daos' ? daos : staticData" :ok="pending"/>
    </div>
  </UCard>
</template>
<script setup lang="ts">
import { getDaos } from "@/dataset/data";
import { data as staticData, imgs } from "@/dataset/dao";

type Props = {
  title?: string;
};
const props = withDefaults(defineProps<Props>(), {
  title: "Daos",
});

const { data, pending } = useAsyncData("getDao", async () => {
  const res = await getDaos();
  return res;
});
type Dao = {
  dao_id?: string;
  dao_name?: string;
  owner?: string;
  title?: string;
  icon?: string;
  description?: string;
};
const daos = ref<Dao[]>();
watch(
  data,
  async (newValue) => {
    if (newValue) {
      const MyDaos = newValue.map((item) => {
        return {
          ...item.data,
          description:
            "A decentralized organization dedicated to stabilizing the value of its stablecoin, DAI, through autonomous interest rate adjustments based on market dynamics.",
          icon: `/images/${imgs[Math.floor(Math.random() * 3)]}.webp`,
        };
      });
      daos.value = MyDaos;
    }
  },
  { immediate: true }
);
</script>
