pub fn strs() {
    let data = "initial contents";
    let s = data.to_string();
    // the method also works on a literal directly:
    let s = "initial contents".to_string();
    // same as:
    let s = String::from("initial contents");

    // updating:
    let mut s1 = String::from("foo");
    let s2 = "bar";
    s1.push_str(s2); // s1.push('l'); // single char
    println!("s2 is {s2}");
    let s1 = String::from("Hello, ");
    let s2 = String::from("world!");
    let s3 = s1 + &s2; // note s1 has been moved here and can no longer be used

    // better for multi-part concatination:
    let s1 = String::from("tic");
    let s2 = String::from("tac");
    let s3 = String::from("toe");

    let s = format!("{s1}-{s2}-{s3}");

    let hello = "Здравствуйте";
    let answer = &hello[0..4];
    println!("{answer}");
    for c in hello.chars() {
        println!("{c}");
    }
    for c in hello.bytes() {
        println!("{c}");
    }
}

pub fn hshs() {
    use std::collections::HashMap;

    let mut scores = HashMap::new();

    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);

    let team_name = String::from("Blue");
    let score = scores.get(&team_name).copied().unwrap_or(0);
    println!("score: {score}");

    for (key, value) in &scores {
        println!("{key}: {value}");
    }
    /*For types that implement the Copy trait, like i32, the values are copied into the hash map.
     * For owned values like String, the values will be moved and the hash map will be the owner of
     * those values */
    let field_name = String::from("Favorite color");
    let field_value = String::from("Blue");

    let mut map = HashMap::new();
    map.insert(field_name, field_value);
    // field_name and field_value are invalid at this point, try using them and
    // see what compiler error you get!

    // updating:
    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Blue"), 25);

    println!("{:?}", scores);  // This code will print {"Blue": 25}. The original value of 10 has been overwritten.

    // add only if not already in
    scores.entry(String::from("Yellow")).or_insert(70);
    scores.entry(String::from("Blue")).or_insert(50);

    println!("{:?}", scores);
    /*By default, HashMap uses a hashing function called SipHash that can provide resistance to
     * Denial of Service (DoS) attacks involving hash tables. It's not the fasted but has good
     * trade-offs. */
}
