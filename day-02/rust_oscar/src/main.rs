use std::fs;

/// This was the bit that took longest
/// 1) I wanted `input` to be either a String or a &str because my test data is &str
/// and I thought my real input would be String (later realised it made sense to pass &str, so this whole thing
/// was pointless anyway). The AsRef<str> trait bound allows this. It says only take arguments
/// which implement AsRef<str> which allows me to call the `as_ref()` method. &str and String implement AsRef<str>
/// 2) As `input` can be &str and we return a reference to the same data we need a lifetime annotation (the 'a).
/// This says the data behind `input` will live as long as the &str in the tuple we return. It's tell the compiler
/// "do not let me drop whatever I passed to this function unless I'm dropping the output of this function
/// at the same time". If I dropped input before the function output I'd have a dangling reference.
fn str_to_tuple<'a, T: AsRef<str>>(input: &'a T) -> (&'a str, i32) {
    let mut split = input.as_ref().split_whitespace();
    (
        split.next().unwrap(),
        split.next().unwrap().parse().unwrap(),
    )
}

fn part1(input: &Vec<&str>) -> i32 {
    let a = input.iter().map(|x| str_to_tuple(x));

    let cords = a.fold((0, 0), |acc, x| match x.0 {
        "up" => (acc.0 - x.1, acc.1),
        "down" => (acc.0 + x.1, acc.1),
        "forward" => (acc.0, acc.1 + x.1),
        _ => panic!("Don't know what this instruction is"),
    });

    cords.0 * cords.1
}

fn part2(input: &Vec<&str>) -> i32 {
    let a = input.iter().map(|x| str_to_tuple(x));

    let cords = a.fold((0, 0, 0), |acc, x| match x.0 {
        "down" => (acc.0, acc.1, acc.2 + x.1),
        "up" => (acc.0, acc.1, acc.2 - x.1),
        "forward" => (acc.0 + acc.2 * x.1, acc.1 + x.1, acc.2),
        _ => panic!("Don't know what this instruction is"),
    });

    cords.0 * cords.1
}

fn main() {
    let file_data = fs::read_to_string("input.txt").unwrap();
    let input = file_data.lines().collect::<Vec<&str>>();

    println!("Day 2 part 1 = {}", part1(&input));
    println!("Day 2 part 2 = {}", part2(&input));
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "forward 5
down 5
forward 8
up 3
down 8
forward 2";

    #[test]
    fn test_str_to_tuple() {
        assert_eq!(str_to_tuple(&"forward 5"), ("forward", 5));
        assert_eq!(str_to_tuple(&"down 10"), ("down", 10));
        assert_eq!(str_to_tuple(&"up 2"), ("up", 2));
        assert_eq!(str_to_tuple(&"back 7"), ("back", 7));
    }

    #[test]
    fn test_part1() {
        assert_eq!(part1(&EXAMPLE.lines().collect()), 150);
    }
    #[test]
    fn test_part2() {
        assert_eq!(part2(&EXAMPLE.lines().collect()), 900);
    }
}
