module QubitCo::Dao{

    use std::option;
    use aptos_framework::coin;
    use aptos_framework::event;

    /// Proposal state
    const PENDING: u8 = 1; // proposal has been created but not ready for voting
    const ACTIVE: u8 = 2;  // proposal is being voted. The DAO is collecting voting results
    const DEFEATED: u8 = 3; // proposal denied because the number of voting is less than the minimum number or deny is more than agree
    const AGREED: u8 = 4; // proposal agreed. But waiting for pre-requisites compromised ready
    const QUEUED: u8 = 5; // pre-requisite ready and waiting for execution
    const EXECUTABLE: u8 = 6; // proposal can be executed
    const EXTRACTED: u8 = 7; // proposal has been executed. This is the final stage of proposal lifecycle



    /// global DAO info of the specified token type `Token`.
    struct DaoGlobalInfo<phantom Token: store> has key {
        /// next proposal id.
        next_proposal_id: u64,
        /// proposal creating event.
        proposal_create_event: event::EventHandle<ProposalCreatedEvent>,
        /// voting event.
        vote_changed_event: event::EventHandle<VoteChangedEvent>,
    }

    /// Configuration of the `Token`'s DAO.
    struct DaoConfig<phantom TokenT: copy + drop + store> has copy, drop, store {
        /// after proposal created, how long use should wait before he can vote (in milliseconds)
        voting_delay: u64,
        /// how long the voting window is (in milliseconds).
        voting_period: u64,
        /// the quorum rate to agree on the proposal.
        /// if 50% votes needed, then the voting_quorum_rate should be 50.
        /// it should between (0, 100].
        voting_quorum_rate: u8,
        /// how long the proposal should wait before it can be executed (in milliseconds).
        min_action_delay: u64,
    }

    /// Proposal data struct
    struct Proposal<phantom Token: store, Action: store> has key {
        /// id of the proposal
        id: u64,
        /// creator of the proposal
        proposer: address,
        /// when voting begins.
        start_time: u64,
        /// when voting ends.
        end_time: u64,
        /// count of voters who agree with the proposal
        for_votes: u128,
        /// count of voters who're against the proposal
        against_votes: u128,
        /// executable after this time.
        eta: u64,
        /// after how long, the agreed proposal can be executed.
        action_delay: u64,
        /// how many votes to reach to make the proposal pass.
        quorum_votes: u128,
        /// proposal action.
        action: option::Option<Action>,
    }

    /// User vote info.
    struct Vote<phantom TokenT: store> has key {
        proposer: address,
        ///prosoal id
        id: u64,
        /// how many tokens to stake
        staake: coin::Coin<TokenT>,
        agree: bool
    }


    const ERR_NOT_AUTHORIZED: u64 = 1401;
    const ERR_ACTION_DELAY_TOO_SMALL: u64 = 1402;
    const ERR_PROPOSAL_STATE_INVALID: u64 = 1403;
    const ERR_PROPOSAL_ID_MISMATCH: u64 = 1404;
    const ERR_PROPOSER_MISMATCH: u64 = 1405;
    const ERR_QUORUM_RATE_INVALID: u64 = 1406;
    const ERR_CONFIG_PARAM_INVALID: u64 = 1407;
    const ERR_VOTE_STATE_MISMATCH: u64 = 1408;
    const ERR_ACTION_MUST_EXIST: u64 = 1409;
    const ERR_VOTED_OTHERS_ALREADY: u64 = 1410;

    ///create a dao config
    public fun new_dao_config<TokenT: copy+drop+store>(
        voting_delay: u64,
        voting_period: u64,
        voting_quorum_rate: u8,
        min_action_delay: u64,
    ): DaoConfig<TokenT> {
        assert!(voting_delay > 0, ERR_CONFIG_PARAM_INVALID);
        assert!(voting_period > 0, ERR_CONFIG_PARAM_INVALID);
        assert!(
            voting_quorum_rate > 0 && voting_quorum_rate <= 100,
            ERR_CONFIG_PARAM_INVALID,
        );
        assert!(min_action_delay > 0, ERR_CONFIG_PARAM_INVALID);
        DaoConfig { voting_delay, voting_period, voting_quorum_rate, min_action_delay }
    }

    public fun propose<TokenT: copy+drop+store, ActionT: copy+drop+store>(
        signer: &signer,
        action: ActionT,
        action_delay: u64,
    ) acquires DaoGlobalInfo {
        if (action_delay == 0) {
            action_delay = min_action_delay<TokenT>();
        } else {
            assert!(action_delay >= min_action_delay<TokenT>(), Errors::invalid_argument(ERR_ACTION_DELAY_TOO_SMALL));
        };
    }



    ///****************************
    /// Events definition
    ///****************************

    /// emitted when proposal created
    struct ProposalCreatedEvent has drop, store {
        proposal_id: u64,
        proposer: address
    }

    /// emitted when user vote/revoke_vote.
    struct VoteChangedEvent has drop, store {
        /// the proposal id.
        proposal_id: u64,
        /// the voter.
        voter: address,
        /// creator of the proposal.
        proposer: address,
        /// agree with the proposal or not
        agree: bool,
        /// latest vote count of the voter.
        vote: u128,
    }






}