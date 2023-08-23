use crate::front_of_house::hosting::add_to_waitlist;

mod front_of_house {
    mod serving {
        fn take_order() {}

        fn serve_order() {}

        fn take_payment() {}
    }

    pub mod hosting {
        pub fn add_to_waitlist() {}
        fn seat_at_table() {}
    }
}

fn deliver_order() {}

mod back_of_house {
    fn fix_incorrect_order() {
        cook_order();
        super::deliver_order();
    }

    fn cook_order() {}

    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String,
    }

    pub enum Appetizer {
        Soup,
        Salad,
    }

    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("peaches"),
            }
        }
    }
}

pub fn eat_at_restaurant() {
    // Absolute path
    crate::front_of_house::hosting::add_to_waitlist();

    // Relative path
    front_of_house::hosting::add_to_waitlist();

    // Scoping
    use crate::front_of_house::hosting; // good practice not to bring the function itself into
                                        // scope!
    hosting::add_to_waitlist();

    // we can also use another name
    use crate::front_of_house::hosting as ho; // different name
    ho::add_to_waitlist();
    // or re-export it:
    pub use crate::front_of_house::hosting as hos; // need to use a different name, though, not not
                                                   // conflict with above


    // Order a breakfast in the summer with Rye toast
    let mut meal = back_of_house::Breakfast::summer("Rye");
    // Change our mind about what bread we'd like
    meal.toast = String::from("Wheat");
    println!("I'd like {} toast please", meal.toast);

    // The next line won't compile if we uncomment it; we're not allowed
    // to see or modify the seasonal fruit that comes with the meal
    // meal.seasonal_fruit = String::from("blueberries");

    // However, enums are public by default:
    let order1 = back_of_house::Appetizer::Soup;
    let order2 = back_of_house::Appetizer::Salad;
}

// we cannot use the scoped `hosting` here, because use is local to
// were we put it (i.e. local to `eat_at_restaurant`)
// hosting::add_to_waitlist()

