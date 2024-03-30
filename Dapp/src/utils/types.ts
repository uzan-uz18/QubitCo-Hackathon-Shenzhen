
import type { MoveValue } from "@aptos-labs/ts-sdk";
export type Proposal = {
    start_time: MoveValue;
    end_time: MoveValue;
    for_votes: MoveValue;
    against_votes: MoveValue;
    eta: MoveValue;
    action_delay: MoveValue;
    quorum_votes: MoveValue;
    action: MoveValue;
    progress?: number;
    idx?: number;
    dao_id?: string;
    owner?: string;
};

export type Dao = {
    dao_id: string;
    dao_name: string;
    owner: string;
    icon?: string;
    description?: string;
};