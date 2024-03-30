module QubitCo::DaoProposeVoteScriptAptosCoin {

    use std::signer::address_of;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::object::{Object, object_address};
    use QubitCo::DaoFactory::Dao;
    use QubitCo::DaoFactory;
    use std::string;
    use aptos_std::smart_vector;


    /*struct DaoAdmins has key{
        dao_admins: smart_vector::SmartVector<DaoAdminAddress>
    }
    struct DaoAdminAddress has store{
        dao_address:address
    }

    fun init_module(init_account:&signer){
        move_to(init_account,DaoAdmins{
            dao_admins: smart_vector::empty<DaoAdminAddress>()
        });
    }*/

    entry fun create_dao(creator:&signer, dao_name:string::String){
        DaoFactory::generate_dao<AptosCoin>(creator,*string::bytes(&dao_name));
    }

    entry fun config_dao(dao_admin:&signer,dao_obj:Object<Dao<AptosCoin>>,voting_delay:u64,voting_period:u64,voting_quorum_rate:u8,random_adjust_enable:string::String){
        DaoFactory::config_dao<AptosCoin>(dao_admin,dao_obj,voting_delay,voting_period,voting_quorum_rate,random_adjust_enable);
    }

    entry fun select_voting_strategy(dao_admin:&signer,dao_obj:Object<Dao<AptosCoin>>,random_adjust_strategy:string::String){
        DaoFactory::config_dao_strategy<AptosCoin>(dao_admin,dao_obj,random_adjust_strategy);
    }

    entry fun propose(proposer:&signer,dao_obj:Object<Dao<AptosCoin>>,
                         action: string::String,
                         action_delay:u64){
        DaoFactory::generate_proposal<AptosCoin>(proposer,dao_obj,*string::bytes(&action),action_delay);
    }

    entry fun redeem(voter:&signer,dao_obj:Object<Dao<AptosCoin>>,proposer_address:address,proposal_idx:u64){
        DaoFactory::redeem(voter,dao_obj,proposer_address,proposal_idx);
    }

    #[randomness]
    entry fun vote(voter: &signer,
        dao_obj: Object<Dao<AptosCoin>>,
        proposer_address: address,
        proposal_id: u64,
        agree: bool,
        stake: u64
    ){
        DaoFactory::cast_vote<AptosCoin>(voter,dao_obj,proposer_address,proposal_id,agree,stake);
    }


    #[event]
    struct ModelEvent has drop, store{
        num:u64
    }


    ///view functions
    #[view]
    public fun query_proposal(dao_obj:Object<Dao<AptosCoin>>,proposal_idx:u64):(u64,u64,u64,u64,u64,u64,u64,string::String) {
        DaoFactory::query_proposal<AptosCoin>(dao_obj,proposal_idx)
    }


}