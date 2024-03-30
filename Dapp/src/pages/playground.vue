<template>
  <div>
    <UButton type="submit" @click="clickH" label="click" :loading="isOk" />
    <div v-for="i in data">
      {{ i }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { AptosClient } from "@/config";
import { getDaos, getVote, getProposals } from "@/dataset/data";
import type { InputTransactionData } from "@aptos-labs/wallet-adapter-core";

// const account = await AptosClient.fundAccount({
//   accountAddress: ADDR,
//   amount: 10,
// });
// console.log(account);

// console.log(AptosClient);
const isOk = ref(false);

// const clickH = async () => {
//   isOk.value = true;
//   let data = await getDaos();
//   isOk.value = false;
//   // const events = data.data.events;
//   console.log(data);
// };

const { data, error, pending, refresh } = useAsyncData("myData", async () => {
  const res = await getProposals();
  return res;
});

const transaction: InputTransactionData = {
  data: {
    function:
      "0xceb1952b202180a3c222a037d45a89e39db8c4227a7e47b5da30f1169bb2791d::DaoProposeVoteScriptAptosCoin::propose",
    functionArguments: [
      "0x94015e7a090a9bc92c343fe6629018e8a860a4f6b17a4a60babdab32fb2ee012",
      "kyodao",
      10000000,
    ],
  },
};

const runFn = async () => {
  const res = await walletCore.signAndSubmitTransaction(transaction);
  await AptosClient.waitForTransaction({
    transactionHash: res.hash,
  });
  console.log("success", res.hash);
};

const viewFn = async () => {
  const a = await AptosClient.view({
    payload: {
      function:
        "0xceb1952b202180a3c222a037d45a89e39db8c4227a7e47b5da30f1169bb2791d::DaoProposeVoteScriptAptosCoin::query_proposal",
      functionArguments: [
        "0x94015e7a090a9bc92c343fe6629018e8a860a4f6b17a4a60babdab32fb2ee012",
        0,
      ],
    },
  });
};
</script>
