use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::fs;
type CardMap = HashMap<u32, (usize, usize)>;

#[derive(Debug)]
struct Card {
    // Map number to its row and column
    lookup: CardMap,
    found_values: Vec<u32>,
    rows: [u32; 5],
    cols: [u32; 5],
}

impl Card {
    fn new(input: &str) -> Self {
        let mut lookup = CardMap::new();
        for (r, row) in input.lines().enumerate() {
            for (c, val) in row.split_whitespace().enumerate() {
                let val = val.parse::<u32>().unwrap();
                lookup.insert(val, (r, c));
            }
        }

        Card {
            lookup,
            found_values: Vec::with_capacity(5 * 5),
            rows: [0; 5],
            cols: [0; 5],
        }
    }
    /// Look up the number in the dictionary and get its location
    /// Add 1 to the rows and cols arrays
    /// If any elements in rows or cols = 5 then bingo, return the column and row its on
    fn call(&mut self, number: u32) -> bool {
        let value = self.lookup.get(&number);
        match value {
            Some(v) => {
                self.rows[v.0] += 1;
                self.cols[v.1] += 1;
                self.found_values.push(number);

                if self.rows.iter().any(|&x| x == 5) | self.cols.iter().any(|&x| x == 5) {
                    return true;
                }
            }
            None => {}
        };

        return false;
    }

    fn play(&mut self, numbers: &Vec<u32>) -> Option<(usize, u32)> {

        for (i, &num) in numbers.iter().enumerate() {
            
            let bingo = self.call(num);

            if bingo {
                
                let found_numbers = &self.found_values;
                let all_numbers: HashSet<&u32> = HashSet::from_iter(self.lookup.keys());
                let ans: Vec<_> = all_numbers
                    .difference(&HashSet::from_iter(found_numbers.iter()))
                    .map(|&x| x)
                    .collect();

                return Some((i, ans.into_iter().map(|&x| x).sum::<u32>() * num));
            }
        }

        return None

    }
}

#[derive(Debug)]
struct Game {
    numbers: Vec<u32>,
    cards: Vec<Card>,
}

impl Game {
    /// Parse the input into a game
    fn new(input: &str) -> Self {
        let mut sections = input.split("\n\n");
        let numbers: Vec<u32> = sections
            .next()
            .unwrap()
            .split(",")
            .map(|x| x.parse::<u32>().unwrap())
            .collect();
        let cards: Vec<Card> =
            sections.map(|card| Card::new(card)).collect();

        Self { numbers, cards }
    }

    ///Solve part 1. Looping over numbers and cards was a nightmare because of the borrow checker
    /// Did the rest in 20 min. This took 3hours!
    /// Update: Part 2 kinda simplified things for me and got rid of the RefCell
    fn part1_and_2(&mut self) -> (u32, u32) {

        let mut all_bingo: Vec<(usize, u32)> = Vec::new();

        for card in self.cards.iter_mut() {
            all_bingo.push(card.play(&self.numbers).unwrap());
        }

        all_bingo.sort_by(|a, b| {a.0.partial_cmp(&b.0).unwrap()});

        
        (all_bingo[0].1, all_bingo[all_bingo.len() - 1].1)
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").expect("Could not read file");
    let mut game = Game::new(&input);

    let ans = game.part1_and_2();
    println!("Part 1 = {}, Part 2 = {}", ans.0, ans.1);
}

#[cfg(test)]
mod tests {

    use super::*;

    const EXAMPLE_CARD: &str = "91 60 70 64 83
    35 41 79 55 31
     7 58 25  3 47
     2 23 69 59 21
    11 22  8 87 90
    ";

    const EXAMPLE_GAME: &str =
        "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
8  2 23  4 24
21  9 14 16  7
6 10  3 18  5
1 12 20 15 19

3 15  0  2 22
9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
2  0 12  3  7";

    #[test]
    fn test_card_row() {
        let mut card = Card::new(EXAMPLE_CARD);
        assert_eq!(card.call(91), false);
        assert_eq!(card.call(60), false);
        assert_eq!(card.call(70), false);
        assert_eq!(card.call(64), false);
        assert_eq!(card.call(83), true);
    }

    #[test]
    fn test_card_col() {
        let mut card = Card::new(EXAMPLE_CARD);
        assert_eq!(card.call(64), false);
        assert_eq!(card.call(55), false);
        assert_eq!(card.call(3), false);
        assert_eq!(card.call(59), false);
        assert_eq!(card.call(87), true);
    }

    #[test]
    fn test_board() {
        let mut game = Game::new(EXAMPLE_GAME);
        let ans = game.part1_and_2();
        assert_eq!(ans.0, 4512);
        assert_eq!(ans.1, 1924);

    }
}
