<template>
    <div :class="[wrapper, height, 'text-4xl']">
        <span>Hello, {{ addr }}</span>
    </div>
</template>

<script setup lang="ts">
import { StorageUtil } from "@/utils/storageUtil";

type Props = {
    addr?: string,
    wrapper?: string,
    height?: string,
}

const props = withDefaults(defineProps<Props>(), {
  wrapper: "flex gap-3",
  height: "h-8",
  addr: "0x00"
});


</script>
