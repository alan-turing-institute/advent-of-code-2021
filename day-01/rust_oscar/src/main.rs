use std::fs;

/// Interesting thing here is windows is not a method on Vec<T>, but a method on
/// [T] (i.e. the slice type). Vec<T> implements the Deref<Target=[T]> trait and [T] has the method
/// windows(). Rust implicitly calls deref() for us.
/// NB: The type of the function argument `input` was originally &Vec<i32>, but I changed it to &[i32] with no
/// other code changes. The function now accepts two types :) 
fn day1_part1(input: &[i32]) -> i32 {
    input.windows(2).map(|x| ((x[1] - x[0]) > 0) as i32).sum()
}

fn day1_part2(input: &[i32]) -> i32 {
    let smoothed: Vec<i32> = input.windows(3).map(|x| x.iter().sum()).collect();
    day1_part1(&smoothed)
}

fn main() {
    let input = fs::read_to_string("input.txt")
        .unwrap()
        .lines()
        .map(|x| x.parse().unwrap())
        .collect::<Vec<i32>>();

    println!("Day 1 Part 1 = {}", day1_part1(&input));

    println!("Day 1 Part 2 = {}", day1_part2(&input));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_example_part_1() {
        let input = vec![199, 200, 208, 210, 200, 207, 240, 269, 260, 263];

        assert_eq!(day1_part1(&input), 7);
    }

    #[test]
    fn test_example_part_2() {
        let input = vec![199, 200, 208, 210, 200, 207, 240, 269, 260, 263];

        assert_eq!(day1_part2(&input), 5);
    }
}
