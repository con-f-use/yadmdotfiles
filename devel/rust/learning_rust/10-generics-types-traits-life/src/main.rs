// GENERICs
// instead of having two functions for integers and chars like this:
//fn largest_i32(list: &[i32]) -> &i32 {}
//fn largest_char(list: &[char]) -> &char {}
// we can have a generic one:

use std::cmp::PartialOrd;

fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];

    for item in list {
        if item > largest {
            // the comparison would make trouble for certain types
            largest = item;
        }
    }

    largest
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];

    let result = largest(&number_list);
    println!("The largest number is {}", result);

    let char_list = vec!['y', 'm', 'a', 'q'];

    let result = largest(&char_list);
    println!("The largest char is {}", result);

    methods_and_strucutres();
    traits();
    lifetimes();
}

fn methods_and_strucutres() {
    struct Point<T> {
        x: T,
        y: T,
    }
    impl<T> Point<T> {
        fn x(&self) -> &T {
            &self.x
        }
    }
    let p = Point { x: 5, y: 10 };
    println!("p.x = {}", p.x());

    // constraint on a generic time (specialization)
    impl Point<f32> {
        fn distance_from_origin(&self) -> f32 {
            (self.x.powi(2) + self.y.powi(2)).sqrt()
        }
    }
    let p = Point { x: 1.1, y: 2.2 };
    println!("p.x = {}, d₀ = {}", p.x(), p.distance_from_origin());
}

fn traits() {
    // Definition
    pub trait Summary {
        // fn summarize(&self) -> String; // without default implementation

        // corresponding default implementation:
        fn summarize(&self) -> String {
            String::from("(Read more...)")
        }
    }

    // Implemantation on two different structs:
    pub struct NewsArticle {
        pub headline: String,
        pub location: String,
        pub author: String,
        pub content: String,
    }

    impl Summary for NewsArticle {
        fn summarize(&self) -> String {
            format!("{}, by {} ({})", self.headline, self.author, self.location)
        }
    }

    pub struct Tweet {
        pub username: String,
        pub content: String,
        pub reply: bool,
        pub retweet: bool,
    }

    impl Summary for Tweet {
        fn summarize(&self) -> String {
            format!("{}: {}", self.username, self.content)
        }
    }

    // Usage
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    };

    println!("1 new tweet: {}", tweet.summarize());

    pub fn _notify(item: &impl Summary) {
        println!("Breaking news! {}", item.summarize());
    }
    // ...is shorthand for trait bound syntax...
    pub fn _notify2<T: Summary>(item: &T) {
        println!("Breaking news! {}", item.summarize());
    }
    // we can even require a type to implement muliple traits:
    pub fn _notify3<T: Summary + Display>(item: &T) {
        println!("Breaking news! {}", item.summarize());
    }
    // and here is some sugar for more complicated typing:
    use std::fmt::{Debug, Display};
    fn _some_function<T, U>(t: &T, u: &U) -> impl Display
    where
        T: Display + Clone,
        U: Clone + Debug,
    {
        println!("{t}{u:?}");
        1
    }
}

fn lifetimes() {
    // communicate to rustc that the returned reference will be valid as 
    // long as both the parameters are valid.
    // note: we do not know at compile time if one of them lives longer
    // and which one is gonna be returned, so the only save assumption
    // is for 'a to live only as long as `x`'s and `y`'s lifetime overlap
    fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
        if x.len() > y.len() {
            x
        } else {
            y
        }
    }
    println!("longest: '{}'", longest("123", "123456"));

    // lifetimes in structs:
    struct ImportantExcerpt<'a> {
        part: &'a str,
    }
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().expect("Could not find a '.'");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
    println!("part {}", i.part);

    // you can elide (noun Elision) lifetimes, if after applying the
    // following rules, no ambigious cases are left:
    // 1.) the compiler tries to assign a lifetime parameter to each parameter that’s a reference
    // 2.) if there is exactly one input lifetime parameter,
    //     that lifetime is assigned to all output lifetime parameters
    // 3.) if there are multiple input lifetimes, but one of them is `&self` or `&mut self`, 
    //     the lifetime of self is assigned to all output lifetime parameters

    // methods and lifetimes:
    impl<'a> ImportantExcerpt<'a> {
        fn _level(&self) -> i32 {
            3
        }
    }
    impl<'a> ImportantExcerpt<'a> {
        fn _announce_and_return_part(&self, announcement: &str) -> &str {
            println!("Attention please: {}", announcement);
            self.part
        }
    }
    // the special lifetime `'static` means the object will live for the
    // entire execution of the program
}
