
struct Number {
    value: u32,
    crossed: bool,
}

impl Number {
    fn new(value: u32) -> Self {
        Number {
            value,
            crossed: false
        }
    }
}

struct Card (Vec<Vec<Number>>);


/// Need to give a bingo number and set the number to checked
/// Need to assert that a row is all checked
/// Need to assert if a column is all checked
impl Card {

    /// Call a number, see if you got it and then check it
    fn call(&mut self, number: u32) {

    }

    /// Check if we got bingo by iterating over all rows and all cols (sure there is a better way as we iterate all numbers twice)
    fn bingo(&self) -> bool {
        false
    }

    fn row_checked(row: Vec<&Number>) -> bool {

        false
    }

    fn col_checked(&self, col: usize) -> bool {
        false
    }

}

fn main() {
    println!("Hello, world!");
}
