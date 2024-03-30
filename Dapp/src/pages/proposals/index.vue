<template>
  <div>
    <UBreadcrumb :links="links" class="mb-10" color="" />
    <DaoProposals />
  </div>
</template>

<script setup lang="ts">
const links = [
  {
    label: "Home",
    icon: "i-heroicons-home",
    to: "/",
  },
  {
    label: "Proposals",
    icon: "i-heroicons-list-bullet-20-solid",
  },
];
</script>
