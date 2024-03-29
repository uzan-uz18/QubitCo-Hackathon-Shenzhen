module QubitCo::GovernStrategy{
    use aptos_std::type_info;
    use aptos_std::type_info::type_of;

    struct RandomModelAdjustment{
        range_min:u64,
        range_max:u64,
        stake:u64
    }

    struct NoAdjustment {
        stake:u64
    }

    friend QubitCo::DaoProposeVoteScriptAptosCoin;
    friend QubitCo::DaoFactory;


    struct AdjustmentStrategy<S> has store {
        strategy: S,
    }


}