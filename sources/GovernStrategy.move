module QubitCo::GovernStrategy{
    use std::signer;
    use std::string;
    use aptos_std::table;
    use aptos_framework::event;
    use aptos_framework::object;
    use aptos_framework::randomness;
    #[test_only]
    use aptos_std::debug;

    friend QubitCo::DaoProposeVoteScriptAptosCoin;
    friend QubitCo::DaoFactory;


    struct GovernStrategyStore has key {
        s_obj_address:address,
    }

    struct ExtendRef has key {
        extend_ref: object::ExtendRef
    }


    struct SimpleLog2ModelRandomAdjustment has key{
        log2_mul1000_lookup_table:table::Table<u64,u64>
    }

    fun init_module(caller:&signer){
        let caller_addr = signer::address_of(caller);
        let obj_ref = object::create_object(caller_addr);
        let obj_signer = object::generate_signer(&obj_ref);
        let obj_extend_ref = object::generate_extend_ref(&obj_ref);


        let s_table=table::new<u64,u64>();
        inialize_SimpleLog2ModelRandomAdjustment_lookup_table(&mut s_table);

        move_to(&obj_signer,SimpleLog2ModelRandomAdjustment{
            log2_mul1000_lookup_table:s_table
        });
        move_to(&obj_signer, ExtendRef{extend_ref:obj_extend_ref});
        move_to(caller,GovernStrategyStore{
            s_obj_address:signer::address_of(&obj_signer)
        });

    }

    public(friend) fun execute_strategy(strategy_name:string::String, stake: u64, supply: u64): u64 acquires GovernStrategyStore, SimpleLog2ModelRandomAdjustment {
        if(string::utf8(b"SimpleLog2ModelRandomAdjustment")==strategy_name){
            return calculate_SimpleLog2ModelRandomAdjustment(stake,supply)
        };
        return stake
    }

    fun calculate_SimpleLog2ModelRandomAdjustment(stake: u64, supply: u64):u64 acquires GovernStrategyStore, SimpleLog2ModelRandomAdjustment {
        let g_store=borrow_global<GovernStrategyStore>(@QubitCo);
        let obj_addr=g_store.s_obj_address;

        let lookup_table_ref=& borrow_global<SimpleLog2ModelRandomAdjustment>(obj_addr).log2_mul1000_lookup_table;

        let log2_mul_1000_r =table::borrow<u64,u64>(lookup_table_ref,stake*100/supply);

        let rate_mul100=51*(*log2_mul_1000_r)/1000;

        if(rate_mul100==0){
            rate_mul100=1;
        };

        let final_take=stake-randomness::u64_range(0,rate_mul100)*stake/100;
        final_take
    }


    fun inialize_SimpleLog2ModelRandomAdjustment_lookup_table(s_table:&mut table::Table<u64,u64>){
        table::add(s_table,0,0);
        table::add(s_table,1,14);
        table::add(s_table,2,29);
        table::add(s_table,3,43);
        table::add(s_table,4,57);
        table::add(s_table,5,71);
        table::add(s_table,6,85);
        table::add(s_table,7,99);
        table::add(s_table,8,112);
        table::add(s_table,9,126);
        table::add(s_table,10,139);
        table::add(s_table,11,152);
        table::add(s_table,12,165);
        table::add(s_table,13,178);
        table::add(s_table,14,191);
        table::add(s_table,15,204);
        table::add(s_table,16,216);
        table::add(s_table,17,229);
        table::add(s_table,18,241);
        table::add(s_table,19,253);
        table::add(s_table,20,265);
        table::add(s_table,21,278);
        table::add(s_table,22,290);
        table::add(s_table,23,301);
        table::add(s_table,24,313);
        table::add(s_table,25,325);
        table::add(s_table,26,336);
        table::add(s_table,27,348);
        table::add(s_table,28,359);
        table::add(s_table,29,371);
        table::add(s_table,30,382);
        table::add(s_table,31,393);
        table::add(s_table,32,404);
        table::add(s_table,33,415);
        table::add(s_table,34,426);
        table::add(s_table,35,437);
        table::add(s_table,36,447);
        table::add(s_table,37,458);
        table::add(s_table,38,469);
        table::add(s_table,39,479);
        table::add(s_table,40,490);
        table::add(s_table,41,500);
        table::add(s_table,42,510);
        table::add(s_table,43,520);
        table::add(s_table,44,531);
        table::add(s_table,45,541);
        table::add(s_table,46,551);
        table::add(s_table,47,560);
        table::add(s_table,48,570);
        table::add(s_table,49,580);
        table::add(s_table,50,590);
        table::add(s_table,51,599);
        table::add(s_table,52,609);
        table::add(s_table,53,619);
        table::add(s_table,54,628);
        table::add(s_table,55,637);
        table::add(s_table,56,647);
        table::add(s_table,57,656);
        table::add(s_table,58,665);
        table::add(s_table,59,674);
        table::add(s_table,60,684);
        table::add(s_table,61,693);
        table::add(s_table,62,702);
        table::add(s_table,63,710);
        table::add(s_table,64,719);
        table::add(s_table,65,728);
        table::add(s_table,66,737);
        table::add(s_table,67,746);
        table::add(s_table,68,754);
        table::add(s_table,69,763);
        table::add(s_table,70,772);
        table::add(s_table,71,780);
        table::add(s_table,72,788);
        table::add(s_table,73,797);
        table::add(s_table,74,805);
        table::add(s_table,75,814);
        table::add(s_table,76,822);
        table::add(s_table,77,830);
        table::add(s_table,78,838);
        table::add(s_table,79,846);
        table::add(s_table,80,854);
        table::add(s_table,81,862);
        table::add(s_table,82,870);
        table::add(s_table,83,878);
        table::add(s_table,84,886);
        table::add(s_table,85,894);
        table::add(s_table,86,902);
        table::add(s_table,87,910);
        table::add(s_table,88,918);
        table::add(s_table,89,925);
        table::add(s_table,90,933);
        table::add(s_table,91,940);
        table::add(s_table,92,948);
        table::add(s_table,93,956);
        table::add(s_table,94,963);
        table::add(s_table,95,971);
        table::add(s_table,96,978);
        table::add(s_table,97,985);
        table::add(s_table,98,993);
        table::add(s_table,99,1000);
    }

    #[test_only]
    struct DebugNum has drop{
        num:u64
    }

    #[event]
    struct EventNum has store,drop{
        num:u64
    }

    #[test(caller=@QubitCo)]
    fun test_calculate_SimpleLog2ModelRandomAdjustment(caller:&signer) acquires GovernStrategyStore, SimpleLog2ModelRandomAdjustment {
        init_module(caller);
        let stake=20;
        let supply=100;
        let g_store=borrow_global<GovernStrategyStore>(@QubitCo);
        let obj_addr=g_store.s_obj_address;

        let lookup_table_ref=& borrow_global<SimpleLog2ModelRandomAdjustment>(obj_addr).log2_mul1000_lookup_table;

        let log2_mul_1000_r =*table::borrow<u64,u64>(lookup_table_ref,stake*100/supply);

        let rate_mul100=51*log2_mul_1000_r/1000;

        let final_take=stake-(rate_mul100-2)*stake/100;

        debug::print(&DebugNum{
            num:final_take
        });
    }



}