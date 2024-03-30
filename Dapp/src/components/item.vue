<template>
  <div>
    <div v-if="loading" class="flex items-center space-x-4 mouse">
      <USkeleton class="h-12 w-12" :ui="{ rounded: 'rounded-full' }" />
      <div class="space-y-2">
        <USkeleton class="h-4 w-[250px]" />
        <USkeleton class="h-4 w-[200px]" />
      </div>
    </div>
    <div v-else>
      <UCard class="flex flex-col items-center gax-y-4 py-10">
        <UAvatar class="h-20 w-20" />
        <div class="text-center">title</div>
        <div class="text-center">description</div>
        <div class="flex justify-center mt-6">
          <UButton variant="outline" color="" to="/proposals">check</UButton>
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
  id?: string;
  loading?: boolean;
};
const props = defineProps<Props>();
</script>
