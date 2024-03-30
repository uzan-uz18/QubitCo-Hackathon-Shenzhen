<template>
  <div
    :class="['logo', wrapper, height, color, { 'cursor-pointer': to }]"
    @click="to ? navigateTo(to) : null"
  >
    <div :class="graph" v-if="showGraph">
      <span :class="['mask graph', height]"></span>
    </div>
    <div :class="text" v-if="showText">
      <span :class="['text-2xl', height]">QubitCo</span>
    </div>
  </div>
</template>

<script setup lang="ts">
/**
 * 属性
 */
type Props = {
  wrapper?: string;
  variant?: "full" | "text" | "graph";
  color?: string;
  height?: string;
  to?: string;
  text?: string;
  graph?: string;
};

const props = withDefaults(defineProps<Props>(), {
  wrapper: "flex gap-3",
  variant: "text",
  height: "h-8",
});

/**
 * 数据
 */
const color = computed(() => {
  let value;
  if (props.color) {
    value = props.color;
  } else {
    value = "text-black dark:text-white";
  }
  return value;
});

const showText = computed(() => {
  return props.variant === "full" || props.variant === "text";
});

const showGraph = computed(() => {
  return props.variant === "full" || props.variant === "graph";
});
</script>

<style lang="postcss">
.logo {
  .mask {
    display: inline-block;
    background-color: currentColor;
    mask-repeat: no-repeat;
    mask-size: 100% 100%;
  }

  .graph {
    aspect-ratio: 1 / 1;
    mask-image: url("/images/logo-graph.png");
  }

  .text {
    aspect-ratio: 16 / 9;
    mask-image: url("/images/logo-text.png");
  }
}
</style>
