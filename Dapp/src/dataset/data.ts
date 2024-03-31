import axios from "axios";
import { AptosClient } from "~/config";
import type { InputTransactionData } from "@aptos-labs/wallet-adapter-core";

type Event = "ProposalCreationEvent" | "DaoCreationEvent" | "VoteEvent";
type EventObject = {
    DAO: Event,
    PROPOSAL: Event,
    VOTE: Event
}

const graphqlEndpoint = "https://api.devnet.aptoslabs.com/v1/graphql";

const ADDR =
    "0xceb1952b202180a3c222a037d45a89e39db8c4227a7e47b5da30f1169bb2791d";
const EVENT: EventObject = {
    DAO: "DaoCreationEvent",
    PROPOSAL: "ProposalCreationEvent",
    VOTE: "VoteEvent"
};




const getDaos = async () => {
    const queryText = `
        query MyQuery {
        events(where: {type: {_eq: "${ADDR}::DaoFactory::${EVENT.DAO}"}}) {
            data
        }
        }`.trim();
    const graphqlRequest = {
        query: queryText,
        variables: null,
        operationName: "MyQuery",
    };
    const res = await axios.post(graphqlEndpoint, graphqlRequest, {
        headers: { "Content-Type": "application/json" },
    })
    return JSON.parse(JSON.stringify(res.data.data.events))
}

const getProposals = async () => {
    const queryText = `
        query MyQuery {
        events(where: {type: {_eq: "${ADDR}::DaoFactory::${EVENT.PROPOSAL}"}}) {
            data
        }
        }`.trim();
    const graphqlRequest = {
        query: queryText,
        variables: null,
        operationName: "MyQuery",
    };
    const res = await axios.post(graphqlEndpoint, graphqlRequest, {
        headers: { "Content-Type": "application/json" },
    })
    return JSON.parse(JSON.stringify(res.data.data.events))
}


const getVote = async () => {
    const queryText = `
        query MyQuery {
        events(where: {type: {_eq: "${ADDR}::DaoFactory::${EVENT.VOTE}"}}) {
            data
        }
        }`.trim();
    const graphqlRequest = {
        query: queryText,
        variables: null,
        operationName: "MyQuery",
    };
    const res = await axios.post(graphqlEndpoint, graphqlRequest, {
        headers: { "Content-Type": "application/json" },
    })
    return JSON.parse(JSON.stringify(res.data.data.events))
}

type Arr = string | number;
const viewFn = async (func: `${string}::${string}::${string}`, arr: Arr[]) => {
    return await AptosClient.view({
        payload: {
            function: func,
            functionArguments: [...arr],
        },
    });
};



const runFn = async (transaction: InputTransactionData) => {
    const res = await walletCore.signAndSubmitTransaction(transaction);
    await AptosClient.waitForTransaction({
        transactionHash: res.hash,
    });
    console.log("success", res.hash);
};


export { getDaos, getProposals, getVote, viewFn, runFn }