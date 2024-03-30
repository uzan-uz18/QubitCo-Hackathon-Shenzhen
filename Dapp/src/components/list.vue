<template>
  <ul
    class="grid grid-cols-3 gap-10 hover:cursor-pointer"
  >
    <li class="block" v-for="i in data" :data-id="i">
      <Item :loading="flag" :data-id="i" />
      
    </li>
  </ul>
</template>

<script setup lang="ts">
type Props = {
  data?: any;
};
const props = withDefaults(defineProps<Props>(), {
  data: [1, 2, 3],
});

const flag = ref(true)

setTimeout(()=>{
  flag.value = false
}, 2000)
</script>
