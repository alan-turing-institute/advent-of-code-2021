use std::{char::ParseCharError, collections::HashMap, fs, str::FromStr};

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    let part1 = Chains::from_str(&input).unwrap().part1(10);
    let part1b = SmartChains::from_str(&input).unwrap().part1(10);

    println!("Part 1 = {}", part1);
    println!("Part 1b = {}", part1b);

    let part2 = SmartChains::from_str(&input).unwrap().part1(40);
    println!("Part 2 = {}", part2);
}

#[derive(Debug)]
struct Chains {
    chains: Vec<char>,
    chain_map: HashMap<(char, char), char>,
}

impl FromStr for Chains {
    type Err = ParseCharError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut chain_map = HashMap::new();
        let (chain_str, map_str) = s.split_once("\n\n").unwrap();
        let chains: Vec<char> = chain_str.chars().collect();
        for line in map_str.lines() {
            let mut line_iter = line.chars();
            chain_map.insert(
                (line_iter.next().unwrap(), line_iter.next().unwrap()),
                line_iter.last().unwrap(),
            );
        }

        Ok(Self { chains, chain_map })
    }
}

impl Iterator for Chains {
    type Item = Vec<char>;

    fn next(&mut self) -> Option<Self::Item> {
        let mut next_chains = self
            .chains
            .windows(2)
            .fold(Vec::new(), |mut acc: Vec<char>, x| {
                acc.push(x[0]);

                if let Some(val) = self.chain_map.get(&(x[0], x[1])) {
                    acc.push(*val);
                }
                acc
            });

        next_chains.push(*self.chains.last().unwrap());

        self.chains = next_chains;

        Some(self.chains.clone())
    }
}

impl Chains {
    fn part1(&mut self, steps: usize) -> i64 {
        let mut counts = HashMap::new();

        let new_chain = self.nth(steps - 1).unwrap();

        for c in new_chain {
            let entry = counts.entry(c).or_insert(0);
            *entry += 1;
        }

        counts.iter().map(|(_, val)| val).max().unwrap()
            - counts.iter().map(|(_, val)| val).min().unwrap()
    }
}

#[derive(Debug)]
struct SmartChains {
    element_count: HashMap<char, usize>,
    pair_count: HashMap<(char, char), usize>,
    chain_map: HashMap<(char, char), char>,
}

impl FromStr for SmartChains {
    type Err = ParseCharError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut chain_map = HashMap::new();
        let mut pair_count = HashMap::new();
        let mut element_count = HashMap::new();

        let (chain_str, map_str) = s.split_once("\n\n").unwrap();

        for c in chain_str.chars() {
            let element = element_count.entry(c).or_insert(0);
            *element += 1;
        }

        for pair in chain_str.chars().collect::<Vec<_>>().windows(2) {
            let element = pair_count.entry((pair[0], pair[1])).or_insert(0);
            *element += 1;
            // pair_count.insert((pair[0], pair[1]), 1);
        }

        for line in map_str.lines() {
            let mut line_iter = line.chars();
            chain_map.insert(
                (line_iter.next().unwrap(), line_iter.next().unwrap()),
                line_iter.last().unwrap(),
            );
        }

        Ok(Self {
            element_count,
            pair_count,
            chain_map,
        })
    }
}

impl Iterator for SmartChains {
    type Item = HashMap<char, usize>;

    fn next(&mut self) -> Option<Self::Item> {
        let mut new_pairs = self.pair_count.clone();

        for (pos_pair, new_c) in self.chain_map.iter() {
            let n_matches = self.pair_count.get(&pos_pair);

            if let Some(k) = n_matches {
                // Increment the element count by the number of matches
                let element = self.element_count.entry(*new_c).or_insert(0);
                *element += k;

                // Increment the pair count
                // How many times did it match
                // Reduce the pair count of th match by the number of inserts
                for p in [(pos_pair.0, *new_c), (*new_c, pos_pair.1)] {
                    let element = new_pairs.entry(p).or_insert(0);
                    *element += k;
                }

                // Decrement pairs that matched and were broken
                let n = new_pairs.get_mut(pos_pair).unwrap();
                *n -= k;
            }
        }

        self.pair_count = new_pairs;
        Some(self.element_count.clone())
    }
}

impl SmartChains {
    fn part1(&mut self, steps: usize) -> i64 {
        let new_chain = self.nth(steps - 1).unwrap();

        new_chain
            .iter()
            .map(|(_, counts)| *counts as i64)
            .max()
            .unwrap()
            - new_chain
                .iter()
                .map(|(_, counts)| *counts as i64)
                .min()
                .unwrap()
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    const EXAMPLE: &str = "NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C";

    #[test]
    fn test_parse() {
        println!("{:?}", Chains::from_str(EXAMPLE));
    }

    #[test]
    fn test_part_1() {
        assert_eq!(1588, Chains::from_str(EXAMPLE).unwrap().part1(10));
        assert_eq!(1588, SmartChains::from_str(EXAMPLE).unwrap().part1(10));
        assert_eq!(
            SmartChains::from_str(EXAMPLE).unwrap().part1(10),
            Chains::from_str(EXAMPLE).unwrap().part1(10)
        );
    }

    #[test]
    fn test_part_2() {
        assert_eq!(
            2188189693529,
            SmartChains::from_str(EXAMPLE).unwrap().part1(40)
        );
    }
}
