<template>
  <UDropdown :items="items">
    <div class="flex gap-4 items-center">
      <UAvatar
        :src="icon"
        alt="Petra icon"
      />
      <div v-if="withName" :class="['text-gray-600 dark:text-gray-400', text]">
        王皓
      </div>
    </div>
  </UDropdown>
</template>

<script setup lang="ts">
import type { DropdownItem } from "@nuxt/ui/dist/runtime/types";
import { wallets } from "@/config";

type Props = { withName?: boolean; text?: string };

defineProps<Props>();

const colorMode = useColorMode();

const currentColorModelIcon = computed(() => {
  switch (colorMode.value) {
    case "light":
      return "i-solar-sun-2-linear";
    case "dark":
      return "i-solar-moon-linear";
  }
});

const icon = wallets[0].icon

const currentItems = ref<"main" | "appearance">("main");

const mainItems = computed<DropdownItem[][]>(() => {
  return [
    [
      {
        label: "User",
        avatar: {
          src: "https://avatars.githubusercontent.com/u/87074006?v=4",
        },
      },
    ],
    [
      {
        label: "Theme",
        icon: currentColorModelIcon.value,
        click: (event: PointerEvent) => {
          event.preventDefault();
          currentItems.value = "appearance";
        },
      },
    ],
  ];
});

const appearanceItems = computed<DropdownItem[][]>(() => {
  return [
    [
      {
        label: "back",
        icon: "i-solar-arrow-left-linear",
        click: (event: PointerEvent) => {
          event.preventDefault();
          currentItems.value = "main";
        },
      },
    ],
    [
      {
        label: "light",
        icon: "i-solar-sun-2-linear",
        click: (event: PointerEvent) => {
          event.preventDefault();
          colorMode.preference = "light";
        },
      },
      {
        label: "black",
        icon: "i-solar-moon-linear",
        click: (event: PointerEvent) => {
          event.preventDefault();
          colorMode.preference = "dark";
        },
      },
      {
        label: "system",
        icon: "i-solar-devices-linear",
        click: (event: PointerEvent) => {
          event.preventDefault();
          colorMode.preference = "system";
        },
      },
    ],
  ];
});

const items = computed(() => {
  switch (currentItems.value) {
    case "appearance":
      return appearanceItems.value;
    default:
      return mainItems.value;
  }
});
</script>
