fn main() {
    #[derive(Debug)]
    enum IpAddrKind { V4, V6 }

    #[derive(Debug)]
    struct IpAddr {
        _kind: IpAddrKind,
        _address: String,
    }
    let four = IpAddrKind::V4;
    let six = IpAddrKind::V6;
    let home = IpAddr {
        _kind: four,
        _address: String::from("127.0.0.1"),
    };
    let loopback = IpAddr {
        _kind: six,
        _address: String::from("::1"),
    };
    println!("{:#?}\n{:#?}", home, loopback);

    // with associated types:
    #[derive(Debug)]
    enum IpAddrTyped {
        V4(u8, u8, u8, u8),
        V6(String),
    }
    let home = IpAddrTyped::V4(127, 0, 0, 1);
    let loopback = IpAddrTyped::V6(String::from("::1"));
    println!("{:#?}\n{:#?}", home, loopback);

    // Option enums: https://doc.rust-lang.org/stable/std/option/enum.Option.html
    // ...and Match
    // basically an enum generic over a type `T` that holds said type or `None`
    // so `None` can be savely handled and `Option<A>` over `A` can be distinguished
    // from `Option<B>` and its `None`
    // `Option` have many things implemented on them.
    #[derive(Debug)]
    enum UsState {
        _Alabama,
        _Alaska,
        // ...
    }
    enum Coin {
        _Penny,
        _Nickel,
        Dime,
        _Quarter(Option<UsState>),
    }
    let coin = Coin::Dime;

    let value = match coin {
        Coin::_Penny => 1,
        Coin::_Nickel => 5,
        Coin::Dime => { println!("Dimes are lucky!"); 10},
        Coin::_Quarter(state) => {
            match state {
                Some(s) => { println!("State quater from {:?}", s); 25 },
                None => 25,
            }
        }, // matches must be exhaustive, to achive that there is catch-all patern in `_ =>` or `other =>`
    };
    println!("There is {} for your coins to the Dollar", 100/value);

    let config_max = Some(3u8);
    match config_max {
        Some(max) => println!("The maximum is configured to be {}", max),
        _ => (),
    }
    if let Some(max) = config_max {  // same as above but shorter
        println!("The maximum is configured to be {}", max);
    } // impled: else { () }
}


