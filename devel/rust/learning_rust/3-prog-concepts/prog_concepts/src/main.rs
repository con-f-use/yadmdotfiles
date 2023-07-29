use std::io;
use std::io::Write;

fn main() {
    //! Some common programing concept and rust behavior.

    ////////////////// VARIABLES
    let mut x = 5; // without `mut` using another `let x = ...;` is called "shadowing"
    println!("The value of x is: {x}");
    x = 6;  // doesn't work without `mut` above - cannot mutate the type, but shadowing could
    println!("The value of x is now: {x}");
    {
        let x = x * 2;
        println!("The value of x in the block is: {x}");
    }
    println!("The value of x outside the block is still: {x}");

    ////////////////// TYPES
    // integer types: (i|u)(8-128|size)
    // let x = 98_123; let x = 0o77;

    /*
    When you’re compiling in release mode with the --release flag,
    Rust does not include checks for integer overflow
    To explicitly handle the possibility of overflow, you can use these
    families of methods provided by the standard library for primitive
    numeric types:
     - Wrap in all modes with the `wrapping_* methods`, such as
       `wrapping_add`.
     - Return the None value if there is overflow with the `checked_*`
        methods.
     - Return the value and a boolean indicating whether there was
        overflow with the `overflowing_* methods`.
     - Saturate at the value’s minimum or maximum values with the
        `saturating_* methods`.
    */
    let c: u8 = b'A'; // 8-bit integers can have ascii char literals!
    let x = read_num(255);
    println!("possible integer overflow at {}?!", c + x);

    let truncated = -5 / 3;
    println!("truncated -5 / 3 = {truncated}");

    let b: bool = false;
    let z: char = 'ℤ';
    let tup: (i32, f64, u8) = (500, 6.4, 1);
    println!("tuple: {tup:?}; unicode char: {z}; boolean: {b}");
    println!("elem: {};", tup.1);  // "elem: {tup.1};" doesn't work
    let months = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"];
    println!("array: {months:?}");  // fixed length, elements of same type
    println!("same value array: {:?}", [2; 15]);

    ////////////////// CONTROL FLOW
    if x % 4 == 0 {
        println!("number is divisible by 4");
    } else if x % 3 == 0 {
        println!("number is divisible by 3");
    } else if x % 2 == 0 {
        println!("number is divisible by 2");
    } else {
        println!("number is not divisible by 4, 3, or 2 or their multiples!");
    }

    let mut counter = 0;
    let result = loop {
        counter += 1;
        if counter == 10 {
            break counter * 2; // note loops can have labels that break can use
        }
    };
    println!("The result is {result}");
    for element in months {
        print!("{element} ");
    }
    println!("");
}


fn read_num(default: u8) -> u8 {
    //! Reads a number from stdin or user input
    let mut maybe_num = String::new();
    print!("Enter a number <-- ");
    io::stdout().flush().unwrap();
    io::stdin()
        .read_line(&mut maybe_num)
        .expect("Wazzup with ya sys, man. Where's the guess?");
    maybe_num = maybe_num.trim().to_string();
    let ret: u8 = match maybe_num.parse() {
        Ok(num) => num,
        Err(_) => {
            println!("'{maybe_num}' ain't no number!");
            default
        }
    };
    ret
}

