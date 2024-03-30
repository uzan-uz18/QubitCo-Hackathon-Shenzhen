<template>
  <UBreadcrumb :links="links" class="mb-10" />
  <div class="flex w-full gap-x-10">
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
          <p>Initiate a Quarterly Community Grant Program</p>
          <div class="flex items-center justify-between">
            <div
              class="flex items-center gap-x-4 text-sm mt-4 text-gray-600 dark:text-gray-300"
            >
              <UAvatar size="sm" />
              <span>User addr</span>
            </div>
            <UButton
              icon="i-solar-square-share-line-outline"
              variant="outline"
              size="sm"
              color=""
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
            <UProgress :value="2" :max="5" />
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
          <UForm
            class="space-y-4"
            @submit="onSubmit"
          >
            <URadioGroup
              v-model="selected"
              :options="options"
            />
            <UButton type="submit" :disabled="!!!selected" > Submit </UButton>
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
        <div class="">title</div>
        <div class="">content</div>
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
        <template #header> title </template>
        <div>content</div>
        <template #footer> time </template>
      </UCard>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRoute } from "vue-router";

const options = [
  {
    value: "yes",
    label: "Yes",
  },
  {
    value: "no",
    label: "No",
  },
  {
    value: "abandon",
    label: "Abandon",
  },
];

const selected = ref("");

const onSubmit= ()=>{
    console.log(selected.value);
}

const route = useRoute();
const proposalId = route.query.id;
console.log(proposalId);
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
    label: "Proposal title",
    icon: "i-heroicons-chat-bubble-oval-left-ellipsis",
  },
];
</script>
