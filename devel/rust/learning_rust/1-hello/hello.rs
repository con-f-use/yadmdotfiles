#![crate_name = "hellowd"]
// rustc hello.rs --crate-type lib
// rustdoc --test --extern doc="libdoc.rlib" hellors
// https://doc.rust-lang.org/book/ch14-02-publishing-to-crates-io.html#making-useful-documentation-comments
// https://doc.rust-lang.org/rustdoc/index.html
// https://doc.rust-lang.org/stable/reference/comments.html#doc-comments

/// Calls main function
fn main2() {
    main();
}

fn main() {
    //! `main` prints `Hello!`
    println!("Hello!");
}
