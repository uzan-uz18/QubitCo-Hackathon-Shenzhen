<template>
  <div>
    <UCard
      :ui="{
        divide: '',
        shadow: '',
        background: 'bg-transparent dark:bg-transparent',
        header: { base: 'text-xl font-bold flex items-center gap-x-4' },
        footer: { base: 'flex items-center justify-between' },
      }"
    >
      <template #header>
        <UAvatar size="3xl" />
        <span>Dao name</span>
      </template>
      <div>
        DAOs are often used for venture capital funding, charitable
        organizations, decentralized finance (DeFi) projects, and more. They
        provide a solid foundation for trustless collaborations, enabling people
        from anywhere in the world to work together towards a common goal
        without needing to trust a central authority.
      </div>
      <template #footer>
        <div>
          <UInput
            icon="i-heroicons-magnifying-glass-20-solid"
            size="lg"
            color="white"
            trailing
            placeholder="Search..."
          />
        </div>
        <div>
          <UButton label="New Proposal" variant="outline" color="" to="/proposals/create" />
        </div>
      </template>
    </UCard>
    <div class="flex flex-col mt-10 gap-y-10">
      <template v-for="i in [1, 2, 3, 4, 5, 6, 7]">
        <UCard>
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-x-4">
              <UAvatar size="sm" />
              <span>User addr</span>
            </div>
            <UBadge>Active</UBadge>
          </div>
          <div class="py-4">
            <p class="font-bold text-xl py-4">
              <ULink
                :to="`/proposals/details?id=1234`"
                active-class="text-primary"
                inactive-class="text-gray-800 dark:text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
              >
                Initiate a Quarterly Community Grant Program
              </ULink>
            </p>
            <p>
              The primary objective of this proposal is to establish a Quarterly
              Community Grant Program within our DAO, aimed at fostering
              innovation, community engagement, and growth. By allocating a
              portion of our treasury funds to support community-driven
              projects, we aim to empower our members and encourage
              contributions that align with our DAO's vision and goals.
            </p>
          </div>
          <div class="py-10">
            <UProgress :value="2" :max="5" />
          </div>
        </UCard>
      </template>
    </div>
  </div>
</template>
