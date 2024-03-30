<template>
  <div class="flex flex-col gap-y-20">
    <div class="flex items-center justify-between">
      <UserHello />
      <UButton label="Create" variant="outline" color="" />
    </div>
    <UDivider class="shadow" />
    <UCard
      :ui="{
        divide: '',
        ring: '',
        shadow: '',
        background: 'bg-transparent dark:bg-transparent',
      }"
    >
      <template #header>
        <span class="text-2xl">My Daos</span>
      </template>
      <div>
        <Dao />
      </div>
    </UCard>
    <UDivider />
    <UCard
      :ui="{
        divide: '',
        ring: '',
        shadow: '',
        background: 'bg-transparent dark:bg-transparent',
      }"
    >
      <template #header> Other Daos </template>
      <div>
        <Dao />
      </div>
    </UCard>
  </div>
</template>

<script setup lang="ts"></script>
