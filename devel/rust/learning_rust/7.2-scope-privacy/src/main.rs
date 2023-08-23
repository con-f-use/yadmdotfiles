// Created with `cargo new --vcs none --name restaurant --lib 7.2-scope-privacy`

// External packages (added as dependenciy in `./Cargo.toml`)
use rand::Rng;

// Using multiple things:
use std::io::{self, Write, Read}; 
// use std::io::*; // globbing exists as well

fn main() {
    let secret_number = rand::thread_rng().gen_range(1..=100);
    println!("Hello from restaurant {}!", secret_number);
}

// the compiler will look for the `front_of_house` module’s code in:
//  - src/front_of_house.rs
//  - src/front_of_house/mod.rs (older style)
// And its submodule `front_of_house`, in:
//  - src/front_of_house/hosting.rs
//  - src/front_of_house/hosting/mod.rs (older style)

