fn main() {
   let mut v = Vec::new();

    v.push(1);
    v.push(2);
    v.push(3);
    v.push(4);

    let first = &v[0];
    // cannot do the following, because value is already borrowed immutably
    // and pushing might re-allocate the entire `v`, invalidating the old
    // reference.
    // v.push(6);
    println!("first: {first} of {:?}", v);

    // by index:
    let v2 = vec![1,2,3];
    let third = &v2[2];
    println!("Third element is {third}");

    // a bit safer:
    let third: Option<&i32> = v.get(2);
    match third {
        Some(third) => println!("The third element is {third}"),
        None => println!("There is no third element."),
    }

    // iteration
    for i in &mut v {
        *i += 50;
        println!("{i}");
    }

    // Enums:
    enum SpreadsheetCell {
        Int(i32),
        Float(f64),
        Text(String),
    }

    let row = vec![
        SpreadsheetCell::Int(3),
        SpreadsheetCell::Text(String::from("blue")),
        SpreadsheetCell::Float(10.12),
    ];

    use collections;  // `collections` is the name of the module
    collections::strs();
    collections::hshs();
}
