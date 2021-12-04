use std::cell::RefCell;
use std::collections::{HashMap, HashSet};

type CardMap = HashMap<u32, (usize, usize)>;
type InverseCardMap = HashMap<(usize, usize), u32>;

#[derive(Debug)]
struct Card {
    // Map number to its row and column
    lookup: CardMap,
    reverse_lookup: InverseCardMap,
    rows: [u32; 5],
    cols: [u32; 5],
}

impl Card {

    fn new(input: &str) -> Self {

        let mut lookup = CardMap::new();
        let mut reverse_lookup = InverseCardMap::new();

        for (r, row) in input.lines().enumerate() {

            for (c, val) in row.split_whitespace().enumerate() {

                let val = val.parse::<u32>().unwrap();
                lookup.insert(val, (r,c));
                reverse_lookup.insert((r,c), val);
            }   
        }

        Card {
            lookup,
            reverse_lookup,
            rows: [0; 5],
            cols: [0; 5],
        }

    }
    /// Look up the number in the dictionary and get its location
    /// Add 1 to the rows and cols arrays
    /// If any elements in rows or cols = 5 then bingo, return the column and row its on
    fn call(&mut self, number: u32) -> (Option<usize>, Option<usize>) {
        let value = self.lookup.get(&number);
        match value {
            Some(v) => {
                self.rows[v.0] += 1;
                self.cols[v.1] += 1;

                let mut winning_row = self.rows
                    .iter()
                    .enumerate()
                    .filter(|(r, &x)| x == 5)
                    .map(|(r, &x)| r);

                let mut winning_col = self.cols
                    .iter()
                    .enumerate()
                    .filter(|(c, &x)| x == 5)
                    .map(|(c, &x)| c);

                
                return (winning_row.next(), winning_col.next());
            }
            None => {}
        };
        return (None, None);
    }

    fn get_row(&self, row: usize) -> Vec<u32> {
        
        (0..5).map(|col: usize| {*(self.reverse_lookup.get(&(row, col)).unwrap()) }).collect()
    }

    fn get_col(&self, col: usize) -> Vec<u32> {
        
        (0..5).map(|row: usize| {*(self.reverse_lookup.get(&(row, col)).unwrap()) }).collect()
    }
}

#[derive(Debug)]
struct Game {
    numbers: Vec<u32>,
    cards: Vec<RefCell<Card>>
}

impl Game {

    /// Parse the input into a game
    fn new(input: &str) -> Self {

        let mut sections = input.split("\n\n");

        let numbers: Vec<u32> = sections.next().unwrap().split(",").map(|x| x.parse::<u32>().unwrap()).collect();

        let cards: Vec<RefCell<Card>> = sections.map(|card| RefCell::new(Card::new(card))).collect();
        
        Self {
            numbers,
            cards
        }
    }

    fn find_winner(&mut self) -> Option<Vec<u32>> {

        for num in self.numbers.iter() {

            for (i,card) in self.cards.iter().enumerate() {
                
                let bingo = card.borrow_mut().call(*num);

                match bingo {
                    (Some(row), None) => {return Some(card.borrow().get_row(row)) },
                    (None, Some(col)) => {return Some(card.borrow().get_col(col)) },
                    _ => {}
                }

            }

        }

        return None
    }
}


fn main() {}


#[cfg(test)]
mod tests {
    use std::borrow::Borrow;

    use super::*;

    const EXAMPLE_CARD: &str = "91 60 70 64 83
    35 41 79 55 31
     7 58 25  3 47
     2 23 69 59 21
    11 22  8 87 90
    ";

    const EXAMPLE_GAME: &str = "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

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
        assert_eq!(card.call(91), (None, None));
        assert_eq!(card.call(60), (None, None));
        assert_eq!(card.call(70), (None, None));
        assert_eq!(card.call(64), (None, None));
        assert_eq!(card.call(83), (Some(0), None));

    }

    #[test]
    fn test_card_col() {
        let mut card = Card::new(EXAMPLE_CARD);
        assert_eq!(card.call(64), (None, None));
        assert_eq!(card.call(55), (None, None));
        assert_eq!(card.call(3), (None, None));
        assert_eq!(card.call(59), (None, None));
        assert_eq!(card.call(87), (None, Some(3)));
    }

    #[test]
    fn test_board() {
        let mut game = Game::new(EXAMPLE_GAME);
        let winner = game.find_winner().unwrap();

        println!("{:?}", winner);

        // let winning_card = &game.cards[winner].borrow();

        // let found_numbers: HashSet<&u32> = HashSet::from_iter(winning_card.lookup.keys());

        // let all_numbers: HashSet<&u32> = HashSet::from_iter(game.numbers.iter());

        // let ans: u32= all_numbers.difference(&found_numbers).map(|&x| x).sum();

        // assert_eq!(winner, 4512)


        // println!("{:?}", &game.cards[winner.unwrap()]);

    }
}