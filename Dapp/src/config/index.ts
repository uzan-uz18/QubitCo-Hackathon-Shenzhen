import { Aptos, AptosConfig, Network } from "@aptos-labs/ts-sdk";
import type { Wallet } from "@aptos-labs/wallet-adapter-core";
import { PetraWallet } from "petra-plugin-wallet-adapter";

export const wallets: Wallet[] = [new PetraWallet()]

export const AptosClient = new Aptos(
    new AptosConfig({
        network: Network.DEVNET
    }),)
