<template>
  <div class="flex flex-col bg-gradient-to-tr from-emerald-50 to-red-50 dark:from-slate-900 dark:to-red-950">
    <LayoutDefaultHeader />
    <LayoutDefaultMain
      class="flex-1 flex flex-col container self-center my-20 px-10"
    >
      <slot></slot>
    </LayoutDefaultMain>
    <LayoutDefaultFooter />
    <Wave />
  </div>
</template>
