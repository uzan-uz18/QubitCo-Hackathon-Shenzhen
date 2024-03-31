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
        <UAvatar
          size="3xl"
          :src="dao.icon"
        />
        <span>{{ dao.dao_name || dao.title }}</span>
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
          <UButton
            label="New Proposal"
            variant="outline"
            :to="`/proposals/create?dao_id=${dao.dao_id}`"
          />
        </div>
      </template>
    </UCard>
    <div class="flex flex-col mt-10 gap-y-10">
      <template v-for="(item, index) of pdata" :key="item?.action">
        <UCard>
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-x-4">
              <UAvatar
                size="sm"
                :src="dao.icon"
              />
              <span>{{ shortenString(data[index].data.proposer, 4, 4) }}</span>
            </div>
            <UBadge>Active</UBadge>
          </div>
          <div class="py-4">
            <p class="font-bold text-xl py-4">
              <ULink
                :to="`/proposals/details?localIndex=${item.idx}-${item.dao_id}`"
                active-class="text-primary"
                inactive-class="text-gray-800 dark:text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
              >
                {{ item?.action }}
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
            <UProgress :value="item?.progress" :max="1" />
          </div>
        </UCard>
      </template>
      <template v-for="i of [1, 2, 3]">
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

<script setup lang="ts">
import { getProposals } from "@/dataset/data";
import { shortenString } from "@/utils/tools";
import { viewFn } from "@/dataset/data";
import type { Proposal } from "@/utils/types";
import type { Dao } from "@/utils/types";
import { useRoute } from "vue-router";
import { imgs } from "@/dataset/dao";

const {
  public: { daoId, addrModules },
} = useRuntimeConfig();

const { data, pending } = useAsyncData("mydata", async () => {
  const res = await getProposals();
  return res;
});

const route = useRoute();
const dao_id = route.query.dao_id as string;
const dao = StorageUtil.getItem(dao_id) as Dao;
console.log(dao);


const pdata = ref<Proposal[] | null>(null);

const fetchProposalDetails = async (proposalIdx: number, owner: string) => {
  const storageData = StorageUtil.getItem(`${proposalIdx}-${daoId}`);
  if (!!storageData) {
    return storageData;
  }
  const proposalResult = await viewFn(
    `${addrModules}query_proposal` as `${string}::${string}::${string}`,
    [daoId, proposalIdx]
  );

  const currentTime = Date.now() * 1000;
  const start_time = Number(proposalResult[0]);
  const end_time = Number(proposalResult[1]);
  const progress = ((currentTime - start_time) / (end_time - start_time)) * 100;
  const clampedProgress = Math.min(Math.max(progress, 0), 100);
  const result = {
    start_time: proposalResult[0],
    end_time: proposalResult[1],
    for_votes: proposalResult[2],
    against_votes: proposalResult[3],
    eta: proposalResult[4],
    action_delay: proposalResult[5],
    quorum_votes: proposalResult[6],
    action: proposalResult[7], // Adjust based on actual structure
    progress: clampedProgress,
    idx: proposalIdx,
    dao_id:
      "0x94015e7a090a9bc92c343fe6629018e8a860a4f6b17a4a60babdab32fb2ee012",
    owner,
  };
  StorageUtil.setItem(`${result.idx}-${result.dao_id}`, result);
  return result;
};

watch(
  data,
  async (newValue) => {
    if (newValue) {
      const proposals = await Promise.all(
        newValue.map((item) => {
          const idx = Number(toRaw(item).data.proposal_idx);
          const proposer = toRaw(item).data.proposer;
          return fetchProposalDetails(idx, proposer);
        })
      );
      pdata.value = proposals;
    }
  },
  { immediate: true }
);
</script>
