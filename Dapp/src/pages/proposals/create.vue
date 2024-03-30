<template>
  <div>
    <UBreadcrumb :links="links" class="mb-10" />
  </div>
  <div class="flex gap-x-10">
    <div class="max-w-5xl w-full">
      <UAccordion :items="items" :ui="{ wrapper: 'flex flex-col w-full' }">
        <template #default="{ item, _index, open }">
          <UButton
            color="gray"
            variant="ghost"
            class="border-b border-gray-200 dark:border-gray-700"
            :ui="{ rounded: 'rounded-none', padding: { sm: 'p-3' } }"
          >
            <template #leading>
              <div class="w-6 h-6flex items-center justify-center -my-1">
                <UIcon :name="item.icon" class="w-6 h-6 dark:text-gray-200" />
              </div>
            </template>

            <span class="truncate">{{ item.label }}</span>

            <template #trailing>
              <UIcon
                name="i-heroicons-chevron-right-20-solid"
                class="w-5 h-5 ms-auto transform transition-transform duration-200"
                :class="[open && 'rotate-90']"
              />
            </template>
          </UButton>
        </template>
      </UAccordion>
      <div class="mt-10">
        <UForm :state="state" class="space-y-4">
          <UFormGroup
            v-slot="{ error }"
            label="Title"
            :error="!state.title && 'You must enter a title'"
            eager-validation
          >
            <UInput
              v-model="state.title"
              type="text"
              placeholder="Enter title"
              :trailing-icon="
                error ? 'i-heroicons-exclamation-triangle-20-solid' : undefined
              "
            />
          </UFormGroup>
          <p>Description (optional)</p>
          <UTextarea
            :padded="false"
            placeholder="Enter..."
            label="Description"
            class="w-full"
            v-model="state.content"
          />
        </UForm>
      </div>
    </div>
    <div>
        <UButton type="submit" label="submit" size="xl" variant="outline" color="" :disabled="!!!state.title" />
    </div>
  </div>
</template>

<script setup lang="ts">
const state = reactive({
  title: undefined,
  content: undefined,
});
const links = [
  {
    label: "Home",
    icon: "i-heroicons-home",
    to: "/",
  },
  {
    label: "Proposals",
    icon: "i-heroicons-list-bullet-20-solid",
    to: "/proposals",
  },
  {
    label: "Create proposal",
    icon: "i-heroicons-chat-bubble-oval-left-ellipsis",
  },
];
const items = [
  {
    label: "Info",
    icon: "i-heroicons-information-circle",
    defaultOpen: true,
    content:
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed neque elit, tristique placerat feugiat ac, facilisis vitae arcu. Proin eget egestas augue. Praesent ut sem nec arcu pellentesque aliquet. Duis dapibus diam vel metus tempus vulputate.",
  },
];
</script>
