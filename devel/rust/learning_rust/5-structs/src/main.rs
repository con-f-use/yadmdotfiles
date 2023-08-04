struct User {
    active: bool,
    username: String,
    email: String,
    sign_in_count: u64,
}

fn main() {
    let user1 = User {
        active: true,
        username: String::from("someusername123"),
        email: String::from("someone@example.com"),
        sign_in_count: 1,
    };
    println!(
        "{}: {} (active: {}, signins: {})",
        user1.username, user1.email, user1.active, user1.sign_in_count
    );
    // user1.email = String::from("altname@example.com")  // worked if `user1` was mutable

    // another shorthand - struct update syntax sugar
    let user2 = User {
        email: String::from("another@example.com"),
        ..user1
    };
    // println!("oh noes, user1 is dead: {}", user1.username);  // DOESN'T WORK ANYMORE because
    // ownership of username string changed over to `user2` in line above!
    println!("user2: {} (active: {})", user2.email, user2.active);

    // Tuple Structs and Unit Structs:
    struct Color(i32, i32, i32);   struct Point(i32, i32, i32);
    let black = Color(0, 0, 0);    let origin = Point(0, 0, 0);
    struct AlwaysEqual;          // declares no data!
    let _subject = AlwaysEqual;  // instance has no data
    println!("{} {}", black.0, origin.1);

    // Debug trait on structs and debug printing (stderr!)
    let scale = 2;
    #[derive(Debug)]
    struct Rectangle { width: u32, height: u32, }
    let rect1 = Rectangle {
        width: dbg!(30*scale),  // `dbg!` takes and returns ownership, btw.
        height: 50,
    };
    println!("rect1 is {:?}\ndegug: {:#?}", rect1, rect1);

    // (struct) methods
    impl Rectangle {
        fn area(&self) -> u32 {  // `&self` short for `self: &Self`
            self.width * self.height
        }
        fn wide(&self) -> bool {
            self.width > 0
        }
        fn can_hold(&self, other: &Rectangle) -> bool {
            self.width > other.width && self.height > other.height
        }
    }
    impl Rectangle {  // multiple impl blocks get merged!
        fn square(size: u32) -> Self {  // "associated function" has no `self`
            Self {
                width: size,
                height: size,
            }
        }
    }
    if rect1.wide() {  // equivalent to `(&rect1).wide()` because of automatic (de-)referencing
            // done by Rust. Matches the function signature of methods (only) for convenience.
        println!("The area of the rectangle is {} px²", rect1.area());
    }
    let rect2 = Rectangle { width: 10, height: 40 };
    let rect3 = Rectangle { width: 60, height: 45 };
    if rect1.can_hold(&rect2) {
        println!("rect2 fits in rect1");
        if ! rect1.can_hold(&rect3) { println!("...but not rect3"); }
    }
    let sq = Rectangle::square(10);
    println!("{:#?}", sq);
}

fn _build_user(email: String, username: String) -> User {
    User {
        active: true,
        username, // equivalent to `username: username,` because function param and field name
        email,    // ...match exactly (same for email) "field init shorthand"
        sign_in_count: 1,
    }
}
