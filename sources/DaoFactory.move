module QubitCo::DaoFactory{

    use std::option;
    use std::signer;
    use std::signer::address_of;
    use std::string;
    use aptos_std::debug;
    use aptos_std::string_utils::to_string;
    use aptos_std::table;
    use aptos_framework::coin;
    use aptos_framework::coin::Coin;
    use aptos_framework::event;
    use aptos_framework::guid;
    use aptos_framework::guid::GUID;
    use aptos_framework::object;
    use aptos_framework::object::{object_exists, Object, ConstructorRef};
    use aptos_framework::timestamp;
    use aptos_framework::voting;
    #[test_only]
    use std::acl::add;
    #[test_only]
    use aptos_std::debug::print;
    #[test_only]
    use aptos_std::string_utils;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_framework::aptos_coin::AptosCoin;
    #[test_only]
    use aptos_framework::object::object_from_constructor_ref;
    #[test_only]
    use aptos_framework::timestamp::set_time_has_started_for_testing;

    /// ************************
    /// Some mock data for demo
    /// ************************
    const TOKEN_SUPPLY:u128=1000_000_000;
    const DEFAULT_MIN_ACTION_DELAY: u64=3600_000;


    const ERROR_NOWNER: u64 = 1;
    const ERR_ACTION_DELAY_TOO_SMALL: u64=10;
    const DUPLICATED_V0TE: u64=20;

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
    struct DaoConfig<phantom TokenT> has store,copy {
        /// after proposal created, how long use should wait before he can vote (in milliseconds)]
        voting_delay: u64,
        /// how long the voting window is (in milliseconds).
        voting_period: u64,
        /// the quorum rate to agree on the proposal.
        /// if 50% votes needed, then the voting_quorum_rate should be 50.
        /// it should between (0, 100].
        voting_quorum_rate: u8,
        ///random punishment enabled or not
        random_adjust_enable: bool
    }

    /// Proposal data struct.
    struct Proposal<phantom Token> has store {
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
        action: option::Option<string::String>,
    }

    struct Proposals<phantom Token> has store {
        id: u64,
        next_proposal_id: u64,
        proposal_table: table::Table<u64,Proposal<Token>>,
    }

    /// User vote info.
    struct Vote<phantom Token> has key {
        /// vote for the proposal under the `proposer`.
        proposer: address,
        /// proposal id.
        id: u64,
        /// how many tokens to stake.
        stake: option::Option<coin::Coin<Token>>,
        /// vote for or vote against.
        agree: bool,
    }

    public entry fun create_dao<Token>(creator:&signer, dao_name:vector<u8>){
        /// each account can only create one DAO
        assert!(!object_exists<Dao<Token>>(address_of(creator)),ERROR_NOWNER);
        /// todo: add staking or cost mechanism
        generate_dao_obj<Token>(creator,dao_name);
    }

    fun generate_dao_obj<Token>(creator:&signer, dao_name:vector<u8>):ConstructorRef {
        let dao_ref=object::create_named_object(creator,dao_name);
        let dao_signer=object::generate_signer(&dao_ref);

        let table=table::new<u64,Proposal<Token>>();

        move_to(&dao_signer,Dao<Token>{
            admin_address:address_of(creator),
            dao_name:string::utf8(dao_name),
            proposals:Proposals<Token>{
                id:0,
                next_proposal_id:0,
                proposal_table:table
            },
            dao_config:DaoConfig<Token>{
                voting_delay:0,
                voting_period:0,
                voting_quorum_rate:50,
                random_adjust_enable: false
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

    public entry fun config_dao<Token>(dao_admin:&signer,dao_obj:Object<Dao<Token>>,voting_delay:u64,voting_period:u64,voting_quorum_rate:u8,random_adjust_enable:bool) acquires Dao {
        ///todo define ERROR CODE in different scenarios
        assert!(object::owns(dao_obj,address_of(dao_admin)),1);
        let obj_address=object::object_address(&dao_obj);
        let dao=borrow_global_mut<Dao<Token>>(obj_address);
        dao.dao_config.voting_period=voting_period;
        dao.dao_config.voting_delay=voting_delay;
        dao.dao_config.voting_quorum_rate=voting_quorum_rate;
        dao.dao_config.random_adjust_enable=random_adjust_enable;
    }


    public entry fun propose<Token>(
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

        let proposal_id=dao.proposals.next_proposal_id;
        dao.proposals.next_proposal_id=proposal_id+1;

        let proposer = signer::address_of(signer);
        let start_time = timestamp::now_microseconds()+dao.dao_config.voting_delay*1000;
        let quorum_votes = quorum_votes<Token>(&dao.dao_config);
        let proposal = Proposal<Token> {
            id: proposal_id,
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
                proposal_id
            }
        );
    }

    ///vote for a proposal
    /// users can vote
    public entry fun cast_vote<Token>(
        voter: &signer,
        proposer_address: address,
        dao_obj: Object<Dao<Token>>,
        proposal_id: u64,
        agree: bool,
    ) acquires Vote, Dao {
        let voter_address = signer::address_of(voter);
        assert!(!has_vote<Token>(voter_address, proposer_address, proposal_id),DUPLICATED_V0TE);
        let dao_obj_addr=object::object_address(&dao_obj);
        let dao= borrow_global_mut<Dao<Token>>(dao_obj_addr);
        let vote=Vote<Token>{
            /// vote for the proposal under the `proposer`.
            proposer: proposer_address,
            /// proposal id.
            id: proposal_id,
            /// how many tokens to stake.
            stake: option::none<Coin<Token>>(),
            /// vote for or vote against.
            agree: agree,
        };


        /// proposal: &mut Proposal<Token>, vote: &mut Vote<Token>, stake: coin::Coin<Token>
        calculate_votes(table::borrow_mut(&mut dao.proposals.proposal_table,proposal_id),&mut vote,coin::balance<Token>(voter_address));

        move_to(voter,vote);

        event::emit(VoteEvent{
            dao_id: dao_obj_addr,
            proposer: proposer_address,
            proposal_id,
            voter_address,
            agree
        });
    }


    ///*****************
    /// util functions
    ///*****************
    public fun quorum_votes<Token>(dao_config:&DaoConfig<Token>):u128 {
        let rate=(dao_config.voting_quorum_rate as u128);
        TOKEN_SUPPLY*rate/100
    }

    /// Check whether voter has voted on proposal with `proposal_id` of `proposer_address`.
    fun has_vote<Token>(
        voter: address,
        proposer_address: address,
        proposal_id: u64,
    ): bool acquires Vote {
        if (!exists<Vote<Token>>(voter)) {
            return false
        };

        let vote = borrow_global<Vote<Token>>(voter);
        vote.proposer == proposer_address && vote.id == proposal_id
    }

    fun calculate_votes<Token>(proposal: &mut Proposal<Token>, vote: &mut Vote<Token>, stake: u64) {
        let stake_value = (stake as u128);
        if (vote.agree) {
            proposal.for_votes = proposal.for_votes + stake_value;
        } else {
            proposal.against_votes = proposal.against_votes + stake_value;
        };
    }

    #[view]
    fun get_dao_config<Token>(dao_owner:&signer):string::String acquires DaoGlobalInfo, Dao {
        let dao_global_info=borrow_global_mut<DaoGlobalInfo<Token>>(signer::address_of(dao_owner));
        let dao_id=dao_global_info.dao_id;

        let dao=borrow_global_mut<Dao<Token>>(dao_id);
        to_string(dao)
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
        proposal_id: u64
    }

    #[event]
    struct VoteEvent has drop, store {
        dao_id: address,
        proposer: address,
        proposal_id: u64,
        voter_address: address,
        agree: bool
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
        create_dao<AptosCoin>(dao_creator, b"TestDAO");
        let dao_global_info=borrow_global_mut<DaoGlobalInfo<AptosCoin>>(signer::address_of(dao_creator));
        let dao_id=dao_global_info.dao_id;

        let dao=borrow_global_mut<Dao<AptosCoin>>(dao_id);

        dao.dao_config.voting_period=1000;
        dao.dao_config.voting_delay=1000;
        dao.dao_config.voting_quorum_rate=60;
        dao.dao_config.random_adjust_enable=true;

        debug::print(&DebugBody{
            body: get_dao_config<AptosCoin>(dao_creator)
        });
    }

    #[test(aptos_signer=@aptos_framework, dao_creator =@0xff, propose_signer=@0xee)]
    public fun test_create_dao_and_propose(aptos_signer:&signer, dao_creator:&signer, propose_signer:&signer) acquires Dao, DaoGlobalInfo {
        let dao_ref=&generate_dao_obj<AptosCoin>(dao_creator,b"a dao");
        set_time_has_started_for_testing(aptos_signer);
        propose(propose_signer,object_from_constructor_ref<Dao<AptosCoin>>(dao_ref),b"do sth",1000_000_000);

        let dao_global_info=borrow_global<DaoGlobalInfo<AptosCoin>>(signer::address_of(dao_creator));
        let dao_id=dao_global_info.dao_id;

        let dao=borrow_global<Dao<AptosCoin>>(dao_id);

        assert!(table::contains(&dao.proposals.proposal_table,dao.proposals.next_proposal_id-1),NO_PROPOSAL_ERR);
    }


/*    #[test(aptos_signer=@aptos_framework, dao_creator =@0xff, propose_signer=@0xee, voter=@0xcc)]
    public fun test_create_dao_and_propose_and_vote(aptos_signer:&signer, dao_creator:&signer, propose_signer:&signer, voter:&signer) acquires Dao, DaoGlobalInfo, Vote {
        let dao_ref=&generate_dao_obj<AptosCoin>(dao_creator,b"a dao");
        set_time_has_started_for_testing(aptos_signer);
        propose(propose_signer,object_from_constructor_ref<Dao<AptosCoin>>(dao_ref),b"do sth",1000_000_000);

        let dao_global_info=borrow_global<DaoGlobalInfo<AptosCoin>>(signer::address_of(dao_creator));
        let dao_id=dao_global_info.dao_id;

        let dao=borrow_global<Dao<AptosCoin>>(dao_id);

        ///public entry fun cast_vote<Token>(
        //         voter: signer,
        //         proposer_address: address,
        //         dao_obj: Object<Dao<Token>>,
        //         proposal_id: u64,
        //         agree: bool,
        //         votes: u128,
        //     )


        cast_vote(voter,signer::address_of(propose_signer),object_from_constructor_ref<Dao<AptosCoin>>(dao_ref),0,true);

        assert!(has_vote<AptosCoin>(signer::address_of(voter),signer::address_of(propose_signer),0),9);
    }*/


}