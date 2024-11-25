module small_shop::better_shop{
    use sui::table::{Table, new};
    use std::ascii::String as AString;
    use sui::balance::{Self, Balance};
    use std::string::String;
    use std::type_name::{Self,};
    use sui::coin::{Self, Coin};

    public struct Shop<phantom T> has key, store{
        id:  UID,
        name: String,
        description: String,
        balance: Balance<T>,
        owner: address,
        trade_coin: AString,
        items: Table<String, u64>,
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
            items: new<String, u64>(ctx),
        };
        transfer::public_share_object(shop);
    }

    public fun add_item<T>(shop: &mut Shop<T>, name: String, price: u64, ctx: &mut TxContext){
        assert!(ctx.sender() == shop.owner, 1);
        assert!(!shop.items.contains(name), 1);
        shop.items.add(name, price);
    }

    public fun remove_item<T>(shop: &mut Shop<T>, name: String, ctx: &mut TxContext){
        assert!(ctx.sender() == shop.owner, 1);
        assert!(shop.items.contains(name), 1);
        shop.items.remove(name);
    }

    public fun update_item<T>(shop: &mut Shop<T>, name: String, price: u64, ctx: &mut TxContext){
        assert!(ctx.sender() == shop.owner, 1);
        assert!(shop.items.contains(name), 1);
        assert!(shop.items.borrow(name) != price, 1);
        *shop.items.borrow_mut(name) = price;
    }

    public fun buy_item<T>(shop: &mut Shop<T>, name: String, pay_coin: Coin<T>){
        assert!(shop.items.contains(name), 1);
        let amount = pay_coin.value();
        let coin_balance : Balance<T> = pay_coin.into_balance();
    
        let coin_type = type_name::get<T>();
        assert!(&coin_type.into_string() == shop.trade_coin, 1);

        let price = shop.items.borrow(name);
        assert!(amount == price, 2);
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

}