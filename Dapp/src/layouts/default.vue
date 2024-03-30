<template>
  <div class="flex flex-col">
    <LayoutDefaultHeader />
    <LayoutDefaultMain class="flex-1 flex flex-col container self-center my-20 px-10">
      <slot></slot>
    </LayoutDefaultMain>
    <LayoutDefaultFooter />
  </div>
</template>
