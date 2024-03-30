<template>
  <UBreadcrumb :links="links" class="mb-10" />
  <div class="flex lg:flex-row flex-col w-full gap-x-10">
    <div class="flex-1">
      <UCard
        class="mb-10"
        :ui="{
          divide: '',
          shadow: '',
          background: 'bg-transparent dark:bg-transparent',
          header: { base: 'text-3xl font-bold' },
          footer: { base: 'flex items-center justify-between' },
        }"
      >
        <template #header>
          <p>{{ detail.action }}</p>
          <div class="flex items-center justify-between">
            <div
              class="flex items-center gap-x-4 text-sm mt-4 text-gray-600 dark:text-gray-300"
            >
              <UAvatar
                size="sm"
                :src="`/images/avatar-${
                  Math.floor(Math.random() * 3) + 1
                }.webp`"
              />
              <span>{{ shortenString(detail.owner, 4, 4) }}</span>
            </div>
            <UButton
              icon="i-solar-square-share-line-outline"
              variant="outline"
              size="sm"
            />
          </div>
        </template>
        <UDivider />
        <div class="pt-10">
          <p>
            Objective: The primary objective of this proposal is to establish a
            Quarterly Community Grant Program within our DAO, aimed at fostering
            innovation, community engagement, and growth. By allocating a
            portion of our treasury funds to support community-driven projects,
            we aim to empower our members and encourage contributions that align
            with our DAO's vision and goals. Background: Our DAO has always been
            a proponent of community-led initiatives. Recognizing the vast pool
            of talent within our community, we believe that providing financial
            support for promising projects can lead to significant advancements
            in our ecosystem. This grant program will serve as a platform for
            innovators and creators to bring their ideas to life, benefiting the
            entire community and beyond. Proposal Details: Funding Allocation: A
            total of $100,000 (equivalent in our DAO's token) will be allocated
            for the first quarter, with subsequent funding amounts to be
            determined based on the program's success and treasury health. Grant
            Categories: Projects will be classified into three main categories:
            Technology Development, Community Events, and Educational Content.
            Each category will have specific criteria and funding limits.
            Application Process: Members wishing to apply for a grant must
            submit a detailed proposal through our DAO's proposal submission
            platform. Proposals will be reviewed by a designated committee
            before being put to a community vote. Evaluation Criteria: Projects
            will be evaluated based on their potential impact on the DAO's
            ecosystem, feasibility, team capability, and alignment with our
            DAO's values and objectives. Reporting Requirements: Grant
            recipients will be required to provide monthly progress reports and
            a final project summary upon completion. Successful projects may be
            featured in our DAO's communications and may qualify for additional
            support. Expected Outcomes: Through the Quarterly Community Grant
            Program, we aim to achieve the following outcomes: Accelerate the
            development of innovative tools and services within our ecosystem.
            Increase member engagement and participation in DAO governance.
            Enhance the visibility and reputation of our DAO in the wider
            blockchain community. Encourage learning and knowledge sharing among
            community members. Conclusion: By approving this proposal, we will
            take a significant step towards nurturing a vibrant and innovative
            community. The Quarterly Community Grant Program represents an
            investment in our collective future, and we look forward to seeing
            the remarkable contributions our members will make with this
            support.
          </p>
        </div>
        <template #footer>
          <div class="py-10 w-full">
            <div class="mb-6">Progress:</div>
            <UProgress :value="detail.progress" :max="100" />
          </div>
        </template>
      </UCard>
      <UCard
        :ui="{
          divide: '',
          shadow: '',
          background: 'bg-transparent dark:bg-transparent',
          header: { base: 'text-lg font-bold flex items-center gap-x-4' },
          footer: { base: 'flex items-center justify-between' },
        }"
      >
        <div class="text-lg font-bold mb-4">Cast your vote</div>
        <div>
          <UForm class="space-y-4" @submit="onSubmit">
            <UFormGroup label="Stake APT" name="stake">
              <UInput placeholder="10" v-model="stake" />
            </UFormGroup>
            <URadioGroup v-model="selected" :options="options" />
            <UButton type="submit" :disabled="!!!selected"> Submit </UButton>
          </UForm>
        </div>
      </UCard>
    </div>
    <div class="flex flex-col gap-y-10">
      <UCard
        :ui="{
          divide: '',
          shadow: '',
          background: 'bg-transparent dark:bg-transparent',
        }"
      >
        <div class="">Information</div>
        <div class="">Start: 2024-04-01 08:00:00</div>
      </UCard>
      <UCard
        :ui="{
          divide: '',
          shadow: '',
          background: 'bg-transparent dark:bg-transparent',
          header: { base: 'text-xl font-bold flex items-center gap-x-4' },
          footer: { base: 'flex items-center justify-between' },
        }"
      >
        <template #header> Current results </template>
        <div>yes: 80%</div>
        <div>no: 20%</div>
        <template #footer> 2024-05-01 08:00:00 End </template>
      </UCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRoute } from "vue-router";
import { viewFn } from "~/dataset/data";
import type { Proposal } from "@/utils/types";
import { shortenString } from "@/utils/tools";
import { runFn } from "@/dataset/data";
import type { InputTransactionData } from "@aptos-labs/wallet-adapter-core";

const toast = useToast();

const {
  public: { daoId, addrModules },
} = useRuntimeConfig();

const options = [
  {
    value: "yes",
    label: "Yes",
  },
  {
    value: "no",
    label: "No",
  },
];

const stake = ref(10);

const selected = ref("");

const agree = computed(() => (selected.value === "yes" ? true : false));

const onSubmit = () => {
  const transaction: InputTransactionData = {
    data: {
      function: `${addrModules}vote` as `${string}::${string}::${string}`,
      functionArguments: [
        toRaw(detail.value).dao_id,
        toRaw(detail.value).owner,
        toRaw(detail.value).idx,
        agree.value,
        stake.value,
      ],
    },
  };
  runFn(transaction)
    .then(() => {
      toast.add({
        id: "1",
        icon: "i-heroicons-check-badge",
        title: "Notification",
        description: "Vote success",
      });
    })
    .catch((error) => {
      toast.add({
        id: "2",
        title: "Notification",
        description: "Vote failed",
        color: "red",
      });
    });
};

const route = useRoute();
const localIndex = route.query.localIndex as string;

const detail = ref<Proposal>(StorageUtil.getItem(localIndex) as Proposal);

onMounted(async () => {
  if (!detail.value) {
    const splitArray: string[] = localIndex.split("-");

    const arr = await viewFn(
      `${addrModules}query_proposal` as `${string}::${string}::${string}`,
      [splitArray[1], Number(splitArray[0])]
    );
    detail.value = arr;
    console.log(detail.value);

    StorageUtil.setItem(localIndex, detail.value);
  }
});

const links = [
  {
    label: "Home",
    icon: "i-heroicons-home",
    to: "/",
  },
  {
    label: "Proposals",
    icon: "i-heroicons-list-bullet-20-solid",
    to: "/proposals",
  },
  {
    label: toRaw(detail.value).action,
    icon: "i-heroicons-chat-bubble-oval-left-ellipsis",
  },
];
</script>
