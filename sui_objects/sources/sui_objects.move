/// Module: sui_objects
module sui_objects::sui_objects{
    use std::string::String;
    use sui::dynamic_field as df;

    public struct Company has key, store{
        id :  UID,
        name : String,
        age : u8,
        owner : address,
    }

    public struct Car has store{
        name : String,
    }

    fun init(ctx: &mut TxContext){
        let company : Company = Company{
            id: object::new(ctx),
            name: b"John".to_string(),
            age: 20,
            owner: ctx.sender(),
        };

        transfer::public_share_object(company);
    }

    public fun give_car(company : &mut Company, car_name : String){
        let car : Car = Car{
            name: car_name,
        };
        df::add(&mut company.id, b"car", car);
    }
}
