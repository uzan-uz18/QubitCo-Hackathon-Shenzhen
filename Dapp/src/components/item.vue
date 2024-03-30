<template>
  <div>
    <div v-if="loading" class="flex items-center space-x-4 mouse">
      <USkeleton class="h-20 w-12" :ui="{ rounded: 'rounded-full' }" />
      <div class="space-y-2">
        <USkeleton class="h-8 w-[250px]" />
        <USkeleton class="h-8 w-[200px]" />
      </div>
    </div>
    <div v-else>
      <UCard class="flex flex-col items-center py-10">
        <UAvatar class="" size="4xl" :src="icon" />
        <div class="text-center font-bold text-2xl mt-4">
          {{ dao_name || title }}
        </div>
        <div class="text-center line-clamp-3 my-5">{{ description }}</div>
        <div class="flex justify-center mt-6">
          <UButton
            class="text-lg font-bold"
            variant="outline"
            to="/proposals"
            size="xl"
            >check</UButton
          >
        </div>
      </UCard>
    </div>
  </div>
</template>

<style scoped>
.mouse:hover {
  @apply shadow-md border;
}
</style>

<script setup lang="ts">
type Props = {
  dao_id?: string;
  dao_name?: string;
  owner?: string;
  title?: string;
  icon?: string;
  description?: string;
  loading?: boolean;
};
const dao = {
  title: "name",
};
const props = withDefaults(defineProps<Props>(), {
  loading: false,
  title: "dao",
  icon: "",
  dao_id: "",
  owner: "",
  dao_name: "",
});
</script>
