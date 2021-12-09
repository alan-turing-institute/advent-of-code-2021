use itertools::Itertools;
use lazy_static::lazy_static;
use rayon::prelude::*;
use regex::Regex;
use std::{
    collections::{HashMap, HashSet},
    fs,
};

fn part1(input: &str) -> usize {
    lazy_static! {
        static ref RE: Regex = Regex::new(r"\b(?:[a-z]{2}|[a-z]{3}|[a-z]{4}|[a-z]{7})\b").unwrap();
    }

    input
        .lines()
        .map(|line| RE.captures_iter(line.split_once("|").unwrap().1).count())
        .sum()
}

/// Map a signal to a vector of hash sets
fn signal_to_set(signal: &str, map: &HashMap<char, char>) -> Vec<HashSet<char>> {
    signal
        .split_whitespace()
        .map(|sig| HashSet::from_iter(sig.chars().map(|c| *map.get(&c).unwrap())))
        .collect()
}

fn part2(input: &str) -> usize {
    let numbers: Vec<HashSet<char>> = vec![
        HashSet::from(['a', 'b', 'c', 'e', 'f', 'g']),
        HashSet::from(['c', 'f']),
        HashSet::from(['a', 'c', 'd', 'e', 'g']),
        HashSet::from(['a', 'c', 'd', 'f', 'g']),
        HashSet::from(['b', 'c', 'd', 'f']),
        HashSet::from(['a', 'b', 'd', 'f', 'g']),
        HashSet::from(['a', 'b', 'd', 'e', 'f', 'g']),
        HashSet::from(['a', 'c', 'f']),
        HashSet::from(['a', 'b', 'c', 'd', 'e', 'f', 'g']),
        HashSet::from(['a', 'b', 'c', 'd', 'f', 'g']),
    ];

    let keys = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];

    // Create an iterator over all possible wire to segment mappings
    input
        .par_lines()
        .map(|line| line.split_once("|").unwrap())
        .map(|(original_signal, outputs)| {
            let values = keys.iter().permutations(7).map(|v| {
                let mut map = HashMap::new();
                keys.into_iter().zip(v).for_each(|(k, &v)| {
                    map.insert(k, v);
                });
                map
            });

            let find_output = |signal: &str| {
                let mut check = values.filter(|map| {
                    signal_to_set(signal, map)
                        .iter()
                        .all(|sig| numbers.contains(sig))
                });

                let wire_to_segment = check.next().unwrap();

                signal_to_set(outputs, &wire_to_segment)
                    .iter()
                    .map(|v| numbers.iter().position(|n| n == v).unwrap())
                    .rev()
                    .enumerate()
                    .fold(0, |acc, x| acc + 10usize.pow(x.0 as u32) * x.1)
            };

            find_output(original_signal)
        })
        .sum()
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    println!("Part 1 = {}", part1(&input));
    println!("Part 2 = {}", part2(&input));
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_part_1() {
        let input: &str = "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe";
        assert_eq!(2, part1(input));

        let big_input: &str =
            "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce";

        assert_eq!(26, part1(big_input));
    }
}
