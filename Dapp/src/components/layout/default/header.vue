<template>
  <header class="flex justify-between py-4 px-6">
    <AppLogo to="/" />
    <UserAccountDropdown />
  </header>
</template>

<style lang="postcss">
.dark-mode {
  @apply bg-black text-white;
}

.light-mode {
  @apply bg-white text-black;
}
</style>

<script setup lang="ts">
const colorMode = useColorMode();
</script>
