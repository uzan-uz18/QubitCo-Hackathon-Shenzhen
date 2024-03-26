module QubitCo::DaoFactory{

    use std::option;
    use std::signer::address_of;
    use std::string;
    use aptos_std::table;
    use aptos_framework::event;
    use aptos_framework::guid;
    use aptos_framework::guid::GUID;
    use aptos_framework::object;
    use aptos_framework::object::{object_exists, Object};

    const ERROR_NOWNER: u64 = 1;

    struct Dao<phantom Token> has key {
        admin_address:address,
        dao_name: string::String,
        proposals: Proposals<Token>,
        dao_config: DaoConfig<Token>
    }

    /// Configuration of the `Token`'s DAO.
    struct DaoConfig<phantom TokenT: copy + drop + store> has copy, drop, store {
        /// after proposal created, how long use should wait before he can vote (in milliseconds)]
        voting_delay: u64,
        /// how long the voting window is (in milliseconds).
        voting_period: u64,
        /// the quorum rate to agree on the proposal.
        /// if 50% votes needed, then the voting_quorum_rate should be 50.
        /// it should between (0, 100].
        voting_quorum_rate: u8,
        /// how long the proposal should wait before it can be executed (in milliseconds).
        min_action_delay: u64,
        ///random punishment enabled or not
        random_adjust_enable: bool
    }

    /// Proposal data struct.
    struct Proposal<phantom Token: store> has key {
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

    struct Proposals<phantom Token> has key {
        id: u64,
        next_proposal_id: u64,
        proposal_table: table::Table<u64,Proposal<Token>>,
    }

    public entry fun create_dao<Token>(creator:&signer, dao_name:vector<u8>):address{
        /// each account can only create one DAO
        assert!(!object_exists<Dao<Token>>(address_of(creator)),ERROR_NOWNER);
        /// todo: add staking or cost mechanism
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
                min_action_delay: 0,
                random_adjust_enable: false
            }
        });

        event::emit(
            DaoCreationEvent{
                owner:address_of(creator),
                dao_id:object::address_from_constructor_ref(&dao_ref),
                dao_name: string::utf8(dao_name)
            }
        );
        object::address_from_constructor_ref(&dao_ref)
    }


    /**
    /// Configuration of the `Token`'s DAO.
    struct DaoConfig<phantom TokenT: copy + drop + store> has copy, drop, store {
        /// after proposal created, how long use should wait before he can vote (in milliseconds)]
        voting_delay: u64,
        /// how long the voting window is (in milliseconds).
        voting_period: u64,
        /// the quorum rate to agree on the proposal.
        /// if 50% votes needed, then the voting_quorum_rate should be 50.
        /// it should between (0, 100].
        voting_quorum_rate: u8,
        /// how long the proposal should wait before it can be executed (in milliseconds).
        min_action_delay: u64,
        ///random punishment enabled or not
        random_punishment_enable: bool
    }
    */
    public entry fun config_dao<Token>(dao_admin:&signer,dao_obj:Object<Token>,voting_delay:u64,voting_period:u64,voting_quorum_rate:u8,min_action_delay:u64,random_adjust_enable:bool) acquires DaoConfig {
        ///todo define ERROR CODE in different scenarios
        assert!(object::owns(dao_obj,address_of(dao_admin)),1);
        let obj_address=object::object_address(&dao_obj);
        let dao_config=borrow_global_mut<DaoConfig<Token>>(obj_address);
        dao_config.voting_period=voting_period;
        dao_config.voting_delay=voting_delay;
        dao_config.voting_quorum_rate=voting_quorum_rate;
        dao_config.min_action_delay=min_action_delay;
        dao_config.random_adjust_enable=random_adjust_enable;
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


}