module QubitCo::DaoFactory{

    use std::fixed_point32::{Self};
    use std::option;
    use std::signer;
    use std::signer::address_of;
    use std::string;
    use aptos_std::string_utils::to_string;
    use aptos_std::table;
    use aptos_framework::coin;
    use aptos_framework::event;
    use aptos_framework::guid;
    use aptos_framework::object;
    use aptos_framework::object::{object_exists, Object, ConstructorRef, object_address};
    use aptos_framework::timestamp;
    use QubitCo::GovernStrategy;

    #[test_only]
    use aptos_std::debug;
    #[test_only]
    use aptos_framework::aptos_coin::AptosCoin;
    #[test_only]
    use aptos_framework::object::object_from_constructor_ref;
    #[test_only]
    use aptos_framework::timestamp::set_time_has_started_for_testing;

    /// ************************
    /// Some mock data for demo
    /// ************************
    const TOKEN_SUPPLY:u64=1000_000_000_000;
    const DEFAULT_MIN_ACTION_DELAY: u64=60_000;
    const MIN_COIN_HOLD_FOR_VOTE:u64 = 100_000_000;

    /// ERROR CODES
    const ERR_ONE_ACCOUNT_ONE_COIN_ONE_DAO: u64 = 1;
    const ERR_ACTION_DELAY_TOO_SMALL: u64=2;
    const ERR_DUPLICATED_V0TE: u64=3;
    const ERR_NO_ENOUGH_BALANCE_FOR_VOTE:u64=4;
    const ERR_NOT_THE_OWNER:u64=5;


    friend QubitCo::DaoProposeVoteScriptAptosCoin;


    struct DaoGlobalInfo<phantom Token> has key{
        dao_id:address
    }

    struct Dao<phantom Token> has key {
        admin_address:address,
        dao_name: string::String,
        proposals: Proposals<Token>,
        dao_config: DaoConfig<Token>
    }

    /// Configuration of the `Token`'s DAO.
    struct DaoConfig<phantom Token> has store,copy {
        /// after proposal created, how long use should wait before he can vote (in milliseconds)]
        voting_delay: u64,
        /// how long the voting window is (in milliseconds).
        voting_period: u64,
        /// the quorum rate to agree on the proposal.
        /// if 50% votes needed, then the voting_quorum_rate should be 50.
        /// it should between (0, 100].
        voting_quorum_rate: u8,
        ///random punishment enabled or not
        weight_adjustment_method: string::String
    }

    /// Proposal data struct.
    struct Proposal<phantom Token> has store {
        /// id of the proposal
        idx: u64,
        /// creator of the proposal
        proposer: address,
        /// when voting begins.
        start_time: u64,
        /// when voting ends.
        end_time: u64,
        /// count of voters who agree with the proposal
        for_votes: u64,
        /// count of voters who're against the proposal
        against_votes: u64,
        /// executable after this time.
        eta: u64,
        /// after how long, the agreed proposal can be executed.
        action_delay: u64,
        /// how many votes to reach to make the proposal pass.
        quorum_votes: u64,
        /// proposal action.
        action: option::Option<string::String>,
    }

    struct Proposals<phantom Token> has store {
        id: u64,
        next_proposal_idx: u64,
        proposal_table: table::Table<u64,Proposal<Token>>,
    }

    /// User vote info.
    struct Vote<phantom Token> has store {
        ///dao object id
        dao_id: address,
        /// vote for the proposal under the `proposer`.
        proposer: address,
        /// proposal id.
        proposal_idx: u64,
        /// how many tokens to stake.
        final_stake: u64,
        /// vote for or vote against.
        agree: bool,
    }

    struct VoteStorage<phantom Token> has key {
        vote_table:table::Table<guid::ID,Vote<Token>>
    }


    public(friend) fun generate_dao<Token>(creator:&signer, dao_name:vector<u8>):ConstructorRef{
        /// each account can only create one DAO
        assert!(!object_exists<Dao<Token>>(address_of(creator)), ERR_ONE_ACCOUNT_ONE_COIN_ONE_DAO);
        /// todo: add staking or cost mechanism
        let dao_ref=object::create_named_object(creator,dao_name);
        let dao_signer=object::generate_signer(&dao_ref);

        let table=table::new<u64,Proposal<Token>>();


        move_to(&dao_signer,Dao<Token>{
            admin_address:address_of(creator),
            dao_name:string::utf8(dao_name),
            proposals:Proposals<Token>{
                id:0,
                next_proposal_idx:0,
                proposal_table:table
            },
            dao_config:DaoConfig<Token>{
                voting_delay:0,
                voting_period:0,
                voting_quorum_rate:50,
                weight_adjustment_method: string::utf8(b"NoAdjustment")
            }
        });

        move_to(creator,DaoGlobalInfo<Token>{
            dao_id:object::address_from_constructor_ref(&dao_ref)
        });

        event::emit(
            DaoCreationEvent{
                owner:address_of(creator),
                dao_id:object::address_from_constructor_ref(&dao_ref),
                dao_name: string::utf8(dao_name)
            }
        );
        dao_ref
    }


    public(friend) fun config_dao<Token>(dao_admin:&signer,dao_obj:Object<Dao<Token>>,voting_delay:u64,voting_period:u64,voting_quorum_rate:u8,rate_adjustment_method:string::String) acquires Dao {
        assert!(object::owns(dao_obj,address_of(dao_admin)),ERR_NOT_THE_OWNER);
        let obj_address=object::object_address(&dao_obj);
        let dao=borrow_global_mut<Dao<Token>>(obj_address);
        dao.dao_config.voting_period=voting_period;
        dao.dao_config.voting_delay=voting_delay;
        dao.dao_config.voting_quorum_rate=voting_quorum_rate;
        dao.dao_config.weight_adjustment_method =rate_adjustment_method;
    }


    public(friend) fun generate_proposal<Token>(
        signer: &signer,
        dao_obj:Object<Dao<Token>>,
        action: vector<u8>,
        action_delay:u64
    ) acquires Dao {
        if(action_delay==0){
            action_delay=DEFAULT_MIN_ACTION_DELAY;
        } else {
            assert!(action_delay >= DEFAULT_MIN_ACTION_DELAY, ERR_ACTION_DELAY_TOO_SMALL);
        };
        let dao_obj_address=object::object_address(&dao_obj);
        let dao : &mut Dao<Token> = borrow_global_mut<Dao<Token>>(dao_obj_address);

        let proposal_id=dao.proposals.next_proposal_idx;
        dao.proposals.next_proposal_idx =proposal_id+1;

        let proposer = signer::address_of(signer);
        let start_time = timestamp::now_microseconds()+dao.dao_config.voting_delay*1000;
        let quorum_votes = quorum_votes<Token>(&dao.dao_config);
        let proposal = Proposal<Token> {
            idx: proposal_id,
            proposer,
            start_time,
            end_time: start_time + dao.dao_config.voting_period*1000,
            for_votes: 0,
            against_votes: 0,
            eta: 0,
            action_delay,
            quorum_votes,
            action: option::some(string::utf8(action)),
        };
        table::add(&mut dao.proposals.proposal_table,proposal_id,proposal);

        event::emit(
            ProposalCreationEvent{
                dao_id:dao_obj_address,
                proposer,
                proposal_idx: proposal_id,
            }
        );
    }

    ///vote for a proposal
    /// users can vote
    public(friend) fun cast_vote<Token>(
        voter: &signer,
        proposer_address: address,
        dao_obj: Object<Dao<Token>>,
        proposal_id: u64,
        agree: bool,
        stake: u64
    ) acquires Dao, VoteStorage {
        assert!(coin::balance<Token>(signer::address_of(voter))>MIN_COIN_HOLD_FOR_VOTE, ERR_NO_ENOUGH_BALANCE_FOR_VOTE);
        assert!(!has_vote<Token>(voter, proposer_address, proposal_id), ERR_DUPLICATED_V0TE);

        let dao=borrow_global_mut<Dao<Token>>(object::object_address(&dao_obj));
        let proposal=table::borrow_mut(&mut dao.proposals.proposal_table,proposal_id);

        let final_stake=GovernStrategy::execute_strategy(dao.dao_config.weight_adjustment_method,stake,TOKEN_SUPPLY);

        let vote=Vote<Token>{
            ///dao object id
            dao_id: object::object_address(&dao_obj),
            /// vote for the proposal under the `proposer`.
            proposer: proposer_address,
            /// proposal id.
            proposal_idx: proposal_id,
            /// how many tokens to stake.
            final_stake,
            /// vote for or vote against.
            agree,
        };

        if (agree) {
            proposal.for_votes = proposal.for_votes + final_stake;
        } else {
            proposal.against_votes = proposal.against_votes + final_stake;
        };

        let proposal_uid=guid::create_id(proposal.proposer,proposal.idx);
        table::add(&mut borrow_global_mut<VoteStorage<Token>>(signer::address_of(voter)).vote_table,proposal_uid,vote);


        event::emit(VoteEvent{
            dao_id: object_address(&dao_obj),
            proposer: proposer_address,
            proposal_id,
            voter_address:address_of(voter),
            agree,
            final_stake
        });
    }


    ///*****************
    /// util functions
    ///*****************
    fun quorum_votes<Token>(dao_config:&DaoConfig<Token>):u64 {
        let rate=(dao_config.voting_quorum_rate as u64);
        TOKEN_SUPPLY*rate/100
    }

    /// Check whether voter has voted on proposal with `proposal_id` of `proposer_address`.
    fun has_vote<Token>(
        voter: &signer,
        proposer_address: address,
        proposal_idx: u64,
    ): bool acquires VoteStorage {
        if (!exists<VoteStorage<Token>>(signer::address_of(voter))) {
            move_to(voter,VoteStorage<Token>{
                vote_table:table::new<guid::ID,Vote<Token>>()
            });
            return false
        };

        let vote_table = &mut borrow_global_mut<VoteStorage<Token>>(signer::address_of(voter)).vote_table;
        let proposal_uid=guid::create_id(proposer_address, proposal_idx);

        if(!table::contains(vote_table,proposal_uid)){
            return false
        };

        table::borrow(vote_table,proposal_uid).proposal_idx== proposal_idx && table::borrow(vote_table,proposal_uid).proposer==proposer_address
    }

    const BASE_ADJUSTMENT_FACTOR: u64 = 100;
    const MAX_RANDOM_ADJUSTMENT: u64 = 5;


    fun get_dao_config<Token>(dao_owner:&signer):string::String acquires DaoGlobalInfo, Dao {
        let dao_global_info=borrow_global_mut<DaoGlobalInfo<Token>>(signer::address_of(dao_owner));
        let dao_id=dao_global_info.dao_id;

        let dao=borrow_global_mut<Dao<Token>>(dao_id);
        to_string(dao)
    }

    fun calculation_model(stake:u64,max_supply:u64):u64{
        //fixed_point32::get_raw_value(math64::log2(fixed_point32::divide_u64(stake,fixed_point32::create_from_u64(max_supply))+1))
        fixed_point32::divide_u64(stake*100,fixed_point32::create_from_u64(max_supply))

    }


    ///*****************
    /// Event definition
    ///*****************
    #[event]
    struct DaoCreationEvent has drop, store {
        owner: address,
        dao_id: address,
        dao_name: string::String
    }

    #[event]
    struct ProposalCreationEvent has drop, store {
        dao_id: address,
        proposer: address,
        proposal_idx: u64,
    }

    #[event]
    struct VoteEvent has drop, store {
        dao_id: address,
        proposer: address,
        proposal_id: u64,
        voter_address: address,
        agree: bool,
        final_stake: u64
    }


    ///// Unit Test
    ///

    #[test_only]
    const NO_PROPOSAL_ERR:u64=110;

    #[test_only]
    struct DebugBody has drop{
        body: string::String
    }

    #[test(dao_creator =@0xff)]
    public fun test_create_dao_and_config(dao_creator:&signer) acquires DaoGlobalInfo, Dao {
        generate_dao<AptosCoin>(dao_creator, b"TestDAO");
        let dao_global_info=borrow_global_mut<DaoGlobalInfo<AptosCoin>>(signer::address_of(dao_creator));
        let dao_id=dao_global_info.dao_id;

        let dao=borrow_global_mut<Dao<AptosCoin>>(dao_id);

        dao.dao_config.voting_period=1000;
        dao.dao_config.voting_delay=1000;
        dao.dao_config.voting_quorum_rate=60;
        dao.dao_config.weight_adjustment_method =string::utf8(b"RandomModelAdjustment");

        debug::print(&DebugBody{
            body: get_dao_config<AptosCoin>(dao_creator)
        });
    }

    #[test(aptos_signer=@aptos_framework, dao_creator =@0xff, propose_signer=@0xee)]
    public fun test_create_dao_and_propose(aptos_signer:&signer, dao_creator:&signer, propose_signer:&signer) acquires Dao, DaoGlobalInfo {
        let dao_ref=&generate_dao<AptosCoin>(dao_creator,b"a dao");
        set_time_has_started_for_testing(aptos_signer);
        generate_proposal(propose_signer,object_from_constructor_ref<Dao<AptosCoin>>(dao_ref),b"do sth",1000_000_000);

        let dao_global_info=borrow_global<DaoGlobalInfo<AptosCoin>>(signer::address_of(dao_creator));
        let dao_id=dao_global_info.dao_id;

        let dao=borrow_global<Dao<AptosCoin>>(dao_id);

        assert!(table::contains(&dao.proposals.proposal_table,dao.proposals.next_proposal_idx -1),NO_PROPOSAL_ERR);
    }


}