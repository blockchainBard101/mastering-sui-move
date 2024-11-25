/// Module: small_shop
module small_shop::small_shop{
    use std::string::String;
    use std::ascii::String as AString;
    // use std::debug::print;
    use sui::dynamic_field as df;
    // use sui::dynamic_object_field as dof;
    use sui::balance::{Self, Balance};
    // use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use std::type_name::{Self,};

    public struct Item has store{
        name: String,
        price: u64,
    }

    public struct Shop<phantom T> has key, store{
        id:  UID,
        name: String,
        description: String,
        balance: Balance<T>,
        owner: address,
        trade_coin: AString,
    }

    public fun create_shop<T>(name: String, description: String, ctx: &mut TxContext){
        let coin_type = type_name::get<T>();
        let shop  = Shop{
            id: object::new(ctx),
            name,
            description,
            balance: balance::zero<T>(),
            owner: ctx.sender(),
            trade_coin: coin_type.into_string(),
        };
        transfer::public_share_object(shop);
    }

    public fun add_item<T>(shop:&mut Shop<T>, name: String, price: u64, ctx: &mut TxContext){
        assert!(ctx.sender() == shop.owner, 1);
        let item : Item = Item{
            name: name,
            price: price,
        };

        df::add(&mut shop.id, name, item);
    }

    public fun buy_item<T>(shop: &mut Shop<T>, name: String, pay_coin: Coin<T>){
        assert!(df::exists_(&shop.id, name), 1);
        let amount = pay_coin.value();
        let coin_balance : Balance<T> = pay_coin.into_balance();
        
        let coin_type = type_name::get<T>();
        // print(&coin_type.into_string());
        assert!(&coin_type.into_string() == shop.trade_coin, 1);
        
        let item : &Item = df::borrow(&shop.id, name);
        // print(&amount);
        // print(&coin_balance);
        assert!(amount == item.price, 2);
        balance::join(&mut shop.balance, coin_balance);  
    }

    public fun withdraw_all<T>(shop: &mut Shop<T>, ctx: &mut TxContext){
        assert!(ctx.sender() == shop.owner, 1);

        let amount = balance::value(&shop.balance);
        // let shop_balance = balance::split(&mut shop.balance, amount);

        let shop_balance = coin::take(&mut shop.balance, amount, ctx);
        transfer::public_transfer(shop_balance, shop.owner);
    }

    public fun withdraw<T>(shop: &mut Shop<T>, amount: u64, ctx: &mut TxContext){
        assert!(ctx.sender() == shop.owner, 1);

        let shop_balance = coin::take(&mut shop.balance, amount, ctx);
        transfer::public_transfer(shop_balance, shop.owner);
    }

    // #[test_only]
    // public fun call_init(ctx: &mut TxContext) {
    //     init(ctx);
    // }
}

