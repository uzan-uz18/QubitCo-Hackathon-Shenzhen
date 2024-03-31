<template>
  <ul class="grid grid-cols-3 gap-10">
    <li
      v-for="(item, index) in data"
      :key="index"
      :data-id="item.dao_id"
      class="block"
    >
      <Item
        :loading="ok"
        :title="item.dao_name || item.title"
        :icon="item.icon"
        :description="item.description"
        :dao_id="item.dao_id"
      />
    </li>
  </ul>
</template>

<script setup lang="ts">
type Dao = {
  dao_id?: string;
  dao_name?: string;
  owner?: string;
  title?: string;
  icon?: string;
  description?: string;
};
type Props = {
  data?: Dao[];
  ok?: boolean;
};
const props = defineProps<Props>();
console.log(props.data);
</script>
