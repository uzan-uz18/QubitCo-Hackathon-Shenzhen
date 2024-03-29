module QubitCo::DaoProposeVoteScriptAptosCoin {

    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::object::Object;
    use QubitCo::DaoFactory::Dao;
    use QubitCo::DaoFactory;
    use std::string;

    public entry fun create_dao(creator:&signer, dao_name:string::String){
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




}