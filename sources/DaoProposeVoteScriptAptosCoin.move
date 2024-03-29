module QubitCo::DaoProposeVoteScriptAptosCoin {

    use std::signer::address_of;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::object::Object;
    use QubitCo::DaoFactory::Dao;
    use QubitCo::DaoFactory;
    use std::string;
    use std::vector;
    use aptos_std::smart_vector;
    #[test_only]
    use std::signer;
    #[test_only]
    use aptos_std::debug;
    #[test_only]
    use aptos_std::string_utils::debug_string;

    struct DaoAdmins has key{
        dao_admins: smart_vector::SmartVector<DaoAdminAddress>
    }
    struct DaoAdminAddress has store{
        dao_address:address
    }

    fun init_module(init_account:&signer){
        move_to(init_account,DaoAdmins{
            dao_admins: smart_vector::empty<DaoAdminAddress>()
        });
    }

    public entry fun create_dao(creator:&signer, dao_name:string::String) acquires DaoAdmins {
        let dao_admin_vector=&mut borrow_global_mut<DaoAdmins>(@QubitCo).dao_admins;
        smart_vector::push_back(dao_admin_vector,DaoAdminAddress{
            dao_address:address_of(creator)
        });
        DaoFactory::generate_dao<AptosCoin>(creator,*string::bytes(&dao_name));
    }

    public entry fun config_dao(dao_admin:&signer,dao_obj:Object<Dao<AptosCoin>>,voting_delay:u64,voting_period:u64,voting_quorum_rate:u8,random_adjust_enable:bool){
        DaoFactory::config_dao<AptosCoin>(dao_admin,dao_obj,voting_delay,voting_period,voting_quorum_rate,random_adjust_enable);
    }

    public entry fun propose(proposer:&signer,dao_obj:Object<Dao<AptosCoin>>,
                         action: string::String,
                         action_delay:u64){
        DaoFactory::generate_proposal<AptosCoin>(proposer,dao_obj,*string::bytes(&action),action_delay);
    }


    public entry fun vote(voter: &signer,
    proposer_address: address,
    dao_obj: Object<Dao<AptosCoin>>,
    proposal_id: u64,
    agree: bool,
    ){
        DaoFactory::cast_vote<AptosCoin>(voter,proposer_address,dao_obj,proposal_id,agree);
    }


    #[test(account=@QubitCo, dao_creator =@0xff)]
    public fun test_create_dao_and_config(account:&signer, dao_creator:&signer) acquires DaoAdmins {
        init_module(account);
        create_dao(dao_creator, string::utf8(b"a dao"));
        let dao_admin_vector=&mut borrow_global_mut<DaoAdmins>(@QubitCo).dao_admins;
        debug::print(smart_vector::borrow(dao_admin_vector,0));
    }




}