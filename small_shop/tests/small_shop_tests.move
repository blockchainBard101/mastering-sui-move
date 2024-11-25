#[test_only]
module small_shop::small_shop_tests{
    // uncomment this line to import the module
    use small_shop::small_shop::{Shop, Self};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_small_shop() {
        use sui::test_scenario as ts;

        let  shop_owner = @0xCAFE;
        let buyer = @0xF00D;

        let mut scenario = ts::begin(shop_owner);
        {
            small_shop::create_shop<SUI>(b"Test Shop".to_string(), b"Test Shop Description".to_string(), scenario.ctx(), );

        };

        scenario.next_tx(shop_owner);{
            let mut shop = scenario.take_shared<Shop<SUI>>();
            small_shop::add_item(&mut shop, b"Biscuit".to_string(), 100, scenario.ctx());
            ts::return_shared<Shop<SUI>>(shop);
        };

        scenario.next_tx(buyer);{
            let mut shop = scenario.take_shared<Shop<SUI>>();
            let sui_coin = coin::mint_for_testing<SUI>(100, scenario.ctx());
            small_shop::buy_item(&mut shop, b"Biscuit".to_string(), sui_coin);
            ts::return_shared<Shop<SUI>>(shop);
        };

        scenario.next_tx(shop_owner);{
            let mut shop = scenario.take_shared<Shop<SUI>>();
            small_shop::withdraw(&mut shop, 10, scenario.ctx());
            ts::return_shared<Shop<SUI>>(shop);
        };

        scenario.next_tx(shop_owner);{
            let mut shop = scenario.take_shared<Shop<SUI>>();
            small_shop::withdraw_all(&mut shop, scenario.ctx());
            ts::return_shared<Shop<SUI>>(shop);
        };
        scenario.end();
    }

    #[test, expected_failure(abort_code = ::small_shop::small_shop_tests::ENotImplemented)]
    fun test_small_shop_fail() {
        abort ENotImplemented
    }
}
