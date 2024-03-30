<template>
  <UDropdown :items="items">
    <div class="flex gap-4 items-center">
      <UAvatar v-if="connectState" :src="user.icon" alt="Petra icon" />
      <div v-else :class="['text-gray-600 dark:text-gray-400', text]">
        connect wallet
      </div>
    </div>
  </UDropdown>
</template>

<script setup lang="ts">
import type { DropdownItem } from "@nuxt/ui/dist/runtime/types";
import { wallets } from "@/config";
import { connect, disconnect, walletCore } from "@/utils/walletUtil";

type Props = { withName?: boolean; text?: string };
type User = { addr?: string; icon?: string };

defineProps<Props>();
const toast = useToast();

// State management
const connectState = useState("connectState", () => false);
const colorMode = useColorMode();
const currentItems = ref<"main" | "appearance">("main");
const user = reactive<User>({});

// Computed properties for dynamic UI elements
const currentColorModelIcon = computed(() =>
  colorMode.value === "light" ? "i-solar-sun-2-linear" : "i-solar-moon-linear"
);

onBeforeMount(() => {
  const addr = StorageUtil.getItem("addr") as string;
  if (addr) {
    connectState.value = true;
    user.addr = addr;
    user.icon = StorageUtil.getItem("icon") as string;
  }
});

// Event handlers
const connectWallets = async (index: number) => {
  connect()
    .then(() => {
      connectState.value = true;
      user.icon = wallets[index].icon;
      user.addr = walletCore?.account?.address;
      StorageUtil.setItem("icon", wallets[index].icon);
      StorageUtil.setItem("addr", walletCore?.account?.address);
      toast.add({
        id: "1",
        icon: "i-heroicons-check-badge",
        title: "Notification",
        description: "Connected",
      });
    })
    .catch((error) => {
      toast.add({
        id: "2",
        title: "Notification",
        description: "Connect failed",
        color: "red",
      });
    });
};

const disconnectWallets = () => {
  disconnect();
  connectState.value = false;
  StorageUtil.removeItem("icon");
  StorageUtil.removeItem("addr");
  toast.add({
    id: "1",
    icon: "i-heroicons-check-badge",
    title: "Notification",
    description: "Disconnected",
  });
};

walletCore.on("connect", () => {
  console.log(user.addr, walletCore?.account?.address);
});

// Dynamic data generation based on state
const connectItems = computed(() =>
  wallets
    .map((item, index) =>
      !connectState.value
        ? {
            label: item.name,
            avatar: { src: item.icon },
            click: () => connectWallets(index),
          }
        : null
    )
    .filter((item) => item)
);
const connectedItems = computed(() => {
  if (!connectState.value) return [];
  return [
    {
      label: user.addr,
      avatar: { src: user.icon },
    },
    {
      label: "disconnect",
      icon: "i-heroicons-arrow-right-on-rectangle",
      click: disconnectWallets,
    },
  ];
});

const mainItems = computed<DropdownItem[][]>(() => [
  [...connectItems.value, ...connectedItems.value],
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
]);

const appearanceItems = computed<DropdownItem[][]>(() => [
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
      label: "dark",
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
]);

const items = computed(() =>
  currentItems.value === "appearance" ? appearanceItems.value : mainItems.value
);
</script>
