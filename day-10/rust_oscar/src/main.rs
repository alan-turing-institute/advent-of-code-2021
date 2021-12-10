use std::fs;

fn is_open(token: char) -> bool {
    match token {
        '[' => true,
        '(' => true,
        '{' => true,
        '<' => true,
        _ => false,
    }
}

fn opening_token(closing_token: char) -> char {
    match closing_token {
        ']' => '[',
        ')' => '(',
        '>' => '<',
        '}' => '{',
        _ => panic!("Not a valid token"),
    }
}

fn find_corruption(line: &str) -> (Option<char>, Vec<char>) {
    let mut stack: Vec<char> = Vec::new();

    for c in line.chars() {
        // Does it open? Push c on stack
        // Does it close? Does is close the last item on the stack? Pop from stack.

        if is_open(c) {
            stack.push(c);
        } else {
            if stack.is_empty() || opening_token(c) != stack[stack.len() - 1] {
                return (Some(c), stack);
            } else {
                stack.pop();
            }
        }
    }
    (None, stack)
}

fn part1(input: &str) -> i64 {
    input
        .lines()
        .map(|line| find_corruption(line))
        .filter(|x| x.0.is_some())
        .map(|x| x.0.unwrap())
        .map(|c| match c {
            ')' => 3,
            ']' => 57,
            '}' => 1197,
            '>' => 25137,
            _ => panic!("Panic!!!!"),
        })
        .sum()
}

fn part2(input: &str) -> i64 {
    let mut scores_on_the_doors: Vec<i64> = input
        .lines()
        .map(|line| find_corruption(line))
        .filter(|(corrupt, _)| corrupt.is_none())
        .map(|(_, stack)| {
            stack.iter().rev().fold(0, |acc: i64, x| {
                let score = match x {
                    '(' => 1,
                    '[' => 2,
                    '{' => 3,
                    '<' => 4,
                    _ => panic!("Should not be on stack"),
                };
                acc * 5 + score
            })
        })
        .collect();

    scores_on_the_doors.sort();

    scores_on_the_doors[scores_on_the_doors.len() / 2]
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    println!("Part 1 = {}", part1(&input));
    println!("Part 2 = {}", part2(&input));
}

#[cfg(test)]
mod tests {

    use super::*;

    const EXAMPLE: &str = "[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]";

    #[test]
    fn test_corruption_checker() {
        assert_eq!('}', find_corruption("{([(<{}[<>[]}>{[]{[(<()>").0.unwrap());
        assert_eq!(')', find_corruption("[[<[([]))<([[{}[[()]]]").0.unwrap());
        assert_eq!(']', find_corruption("[{[{({}]{}}([{[{{{}}([]").0.unwrap());
        assert_eq!(')', find_corruption("[<(<(<(<{}))><([]([]()").0.unwrap());
        assert_eq!('>', find_corruption("<{([([[(<>()){}]>(<<{{").0.unwrap());
    }

    #[test]
    fn test_part_1() {
        assert_eq!(26397, part1(&EXAMPLE));
    }

    #[test]
    fn test_part_2() {
        assert_eq!(288957, part2(&EXAMPLE));
    }
}
