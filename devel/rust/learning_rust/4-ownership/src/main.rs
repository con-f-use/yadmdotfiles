// Ownership, References, Slices

fn main() {
    println!("This is useless without the source code!");
    /* > Rust will never automatically create “deep” copies of your data. Therefore, any automatic
     * > copying can be assumed to be inexpensive in terms of runtime performance. */
    // let s1 = String::from("hello");
    // let s2 = s1;
    // println!("{}, world!", s1);  error[E0382]: borrow of moved value: `s1`

    /* Rust has a special annotation called the Copy trait that we can place on types that are
     * stored on the stack. If a type implements the Copy trait, variables that use it do not move,
     * but rather are trivially copied. Rust won’t let us annotate a type with Copy if the type, or
     * any of its parts, has implemented the Drop trait. */
    let x = 5;
    let y = x;
    println!("x = {}, y = {}", x, y);

    let s = String::from("hello"); // s comes into scope
    takes_ownership(s); // s's value moves into the function...
                        // ... and so is no longer valid here
    let x = 5; // x comes into scope
    makes_copy(x); // x would move into the function,
                   // but i32 is Copy, so it's okay to still
                   // use x afterward

    let _s1 = gives_ownership(); // gives_ownership moves its return value into s1
    let s2 = String::from("hello"); // s2 comes into scope
    let _s3 = takes_and_gives_back(s2); // s2 is moved into
                                        // takes_and_gives_back, which also
                                        // moves its return value into s3
                                        // Here, s3 goes out of scope and is dropped. s2 was moved, so nothing happens.
                                        // s1 goes out of scope and is dropped.

    let s1 = String::from("hello");
    let (s2, len) = calculate_length(s1);
    println!("The length of '{}' is {}.", s2, len);

    // Pass by reference (we never have ownership thus need not return it)
    let s1 = String::from("hello");
    let len = calculate_len_ref(&s1); // `&` is referencing, `*` is dereferencing
    println!("The length of '{}' is {}.", s1, len);

    // Change a reference
    let mut s = String::from("hello");
    let r1 = &mut s;
    // let r2 = &mut s;  // would fail, there can only be one mutable reference
    // would work like this:
    // {
    //     let r1 = &mut s;
    // } // r1 goes out of scope here, so we can make a new reference with no problems.
    // let r2 = &mut s;
    mut_ref(r1);

    // similarly mixing mutable and immutable
    let mut s = String::from("hello");
    let _r1 = &s; // no problem
    let r3 = &mut s; // BIG PROBLEM
    // println!("{_r1}"); // but only when used, because scope of `r1` ended before `let r3`
                         // uncomment the print and it'll implode!
    println!("{r3}");

    // let reference_to_nowhere = dangle();  // "dangling pointer" not allowed!
    /* At any given time, you can have either one mutable reference or any number of immutable
     * references. References must always be valid! */

    let mut sen = String::from("First words are lame!");
    let w = first_word(&sen);
    // w.clear(); // error! (since we're using it next)
    println!("{}", w);
}

fn takes_ownership(some_string: String) {
    // some_string comes into scope
    println!("{}", some_string);
} // Here, some_string goes out of scope and `drop` is called. The backing memory is freed.

fn makes_copy(some_integer: i32) {
    // some_integer comes into scope
    println!("{}", some_integer);
} // Here, some_integer goes out of scope. Nothing special happens.

fn gives_ownership() -> String {
    // gives_ownership will move its
    // return value into the function
    // that calls it

    let some_string = String::from("yours"); // some_string comes into scope

    some_string // some_string is returned and moves out to the calling function
}

// This function takes a String and returns one
fn takes_and_gives_back(a_string: String) -> String {
    // a_string comes into
    // scope

    a_string // a_string is returned and moves out to the calling function
}

fn calculate_length(s: String) -> (String, usize) {
    let length = s.len(); // len() returns the length of a String
    (s, length)
}

fn calculate_len_ref(s: &String) -> usize {
    s.len()
    /* The scope in which the variable s is valid is the same as any function parameter’s scope,
     * but the value pointed to by the reference is not dropped when s stops being used, because s
     * doesn’t have ownership. When functions have references as parameters instead of the actual
     * values, we won’t need to return the values in order to give back ownership, because we never
     * had ownership. */
}

fn mut_ref(some_string: &mut String) {
    some_string.push_str(", world");
}

// fn dangle() -> &String {
//     /* In Rust, by contrast, the compiler guarantees that references will never be dangling
//      * references, the compiler will ensure that the data will not go out of scope before the
//      * reference to the data does. */
//     let s = String::from("hello");
//     &s  // the solution here would be to just return `s` directly
// }

/* String slice range indices must occur at valid UTF-8 character boundaries. If you attempt to
 * create a string slice in the middle of a multibyte character, your program will exit with an
 * error. For the purposes of introducing string slices, we are assuming ASCII only. */

fn first_word(s: &String) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i]; // could be written as `[..i]` and `[..]` a slice of the whole string
        }
    }

    &s[..]
}
