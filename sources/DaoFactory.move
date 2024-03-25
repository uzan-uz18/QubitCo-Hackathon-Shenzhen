module QubitCo::DaoFactory{

    use std::signer::address_of;
    use std::string;
    use aptos_std::table;
    use aptos_framework::event;
    use aptos_framework::guid;
    use aptos_framework::guid::GUID;
    use aptos_framework::object;
    use aptos_framework::object::object_exists;

    const ERROR_NOWNER: u64 = 1;

    struct Dao<phantom Token> has key {
        admin_address:address,
        proposals: Proposals<Token>
    }

    struct Proposal<phantom Token> has store, copy {
        id: u64,
        content: string::String,
    }

    struct Proposals<phantom Token> has key {
        id: u64,
        next_proposal_id: u64,
        proposal_table: table::Table<u64,Proposal<Token>>,
    }

    public entry fun create_dao<Token>(creator:&signer, dao_name:vector<u8>){
        /// each account can only create one DAO
        assert!(!object_exists<Dao<Token>>(address_of(creator)),ERROR_NOWNER);
        /// todo: add staking or cost mechanism
        let dao_ref=object::create_named_object(creator,dao_name);
        let dao_signer=object::generate_signer(&dao_ref);

        let table=table::new<u64,Proposal<Token>>();

        move_to(&dao_signer,Dao<Token>{
            admin_address:address_of(creator),
            proposals:Proposals<Token>{
                id:0,
                next_proposal_id:0,
                proposal_table:table
            }
        });

        event::emit(
            DaoCreationEvent{
                owner:address_of(creator),
                dao_id:object::address_from_constructor_ref(&dao_ref),
                dao_name: string::utf8(dao_name)
            }
        );
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