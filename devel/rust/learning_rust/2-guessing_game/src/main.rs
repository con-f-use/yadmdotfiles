use std::io;
use std::io::Write;
use std::cmp::Ordering;
use rand::Rng;  // `cargo doc --open` gives docs on everything you use

fn main() {
    //! A small guessing game with an attitude
    println!("Guess the number, yo! Is integer beween 0 and 100!");

    print!("Gimme ya guess, brah <-- ");
    io::stdout().flush().unwrap();
    let correct_nbr = rand::thread_rng().gen_range(0..=10);

    loop {
        let mut guess = String::new();
        io::stdin() // could've been used without the import as std::io::stdin()
                    // return a type std::io::Stdin
            .read_line(&mut guess)
            .expect("Wazzup with ya sys, man. Where's the guess?");
        guess = guess.trim().to_string();
        let guess: u32 = match guess.parse() {
            Ok(num) => num,
            Err(_) => {
                println!("'{guess}' ain't no number!");
                continue;
            }
        };
        if guess > 10 {
            println!("Yo, I sad 0 to 10, yo!");
            continue;
        }

        println!("You think it's '{guess}'?\nLemme see...");

        match guess.cmp(&correct_nbr) {
            Ordering::Less => println!("Nope, 2 smoll, boo!"),
            Ordering::Greater => println!("Nah, way too big, breh!"),
            Ordering::Equal => {
                println!("✔ It's a winner!");
                break;
            }
        };
        println!{"\n"}
    }
}
