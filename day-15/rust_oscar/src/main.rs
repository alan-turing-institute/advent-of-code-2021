use std::{fmt::Debug, fs, num::ParseIntError, str::FromStr};

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    let part1 = RiskMap::from_str(&input).unwrap().find_cost_map()[0][0] - 1;
    println!("Part 1 = {}", part1);

    let part2 = RiskMap::from_str(&input)
        .unwrap()
        .bigger_risk_map()
        .find_cost_map()[0][0]
        - 1;
    println!("Part 2 = {}", part2);
}

#[derive(Debug)]
struct RiskMap {
    risk: Vec<Vec<u64>>,
    expected_risk: Vec<Vec<Option<u64>>>,
}


impl RiskMap {
    fn min_expected_risk(&self, pos: (usize, usize)) -> Option<u64> {
        let r = self.risk[pos.0][pos.1];

        if pos.0 == self.risk.len() - 1 && pos.1 == self.risk[0].len() - 1 {
            return Some(r);
        }

        let offsets = [(0, 1), (1, 0), (-1, 0), (0, -1)];

        let best_neighbour = offsets
            .iter()
            .map(|(x, y)| (pos.0 as i32 + x, pos.1 as i32 + y))
            .filter(|neighbour| {
                neighbour.0 >= 0
                    && neighbour.0 < self.expected_risk.len() as i32
                    && neighbour.1 >= 0
                    && neighbour.1 < self.expected_risk[0].len() as i32
            })
            .map(|(x, y)| self.expected_risk[x as usize][y as usize])
            .filter(|neighbour| neighbour.is_some())
            .map(|neighbour| neighbour.unwrap())
            .min();

        match best_neighbour {
            Some(expected_cost) => Some(r + expected_cost),
            None => None,
        }
    }

    fn find_cost_map(&mut self) -> Vec<Vec<u64>> {
        self.by_ref().take_while(|diff| *diff != 0).last();
        self.next().unwrap();

        self.expected_risk
            .iter()
            .map(|row| row.iter().map(|elem| elem.unwrap()).collect())
            .collect::<Vec<Vec<u64>>>()
    }

    fn bigger_risk_map(&self) -> Self {
        let mut new_risk = vec![];

        for row in 0..self.risk.len() * 5 {
            new_risk.push(vec![]);

            for col in 0..self.risk[0].len() * 5 {
                let real_row = row % self.risk.len();
                let real_col = col % self.risk[0].len();

                new_risk[row].push({
                    let new_elem = self.risk[real_row][real_col]
                        + (row / self.risk.len()) as u64
                        + (col / self.risk[0].len()) as u64;

                    if new_elem < 10 {
                        new_elem
                    } else {
                        new_elem % 10 + 1
                    }
                });
            }
        }

        let expected_risk = vec![vec![None; new_risk[0].len()]; new_risk.len()];

        Self {
            risk: new_risk,
            expected_risk,
        }
    }
}

impl FromStr for RiskMap {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let risk: Vec<Vec<u64>> = s
            .lines()
            .map(|row| {
                row.chars()
                    .map(|x| x.to_digit(10).unwrap() as u64)
                    .collect::<Vec<u64>>()
            })
            .collect();

        let expected_risk = vec![vec![None; risk[0].len()]; risk.len()];

        Ok(Self {
            risk,
            expected_risk,
        })
    }
}

impl Iterator for RiskMap {
    type Item = i64;

    fn next(&mut self) -> Option<Self::Item> {
        let new_expected_risk: Vec<Vec<Option<u64>>> = self
            .expected_risk
            .iter()
            .enumerate()
            .map(|(x, row)| {
                row.iter()
                    .enumerate()
                    .map(|(y, _)| self.min_expected_risk((x, y)))
                    .collect()
            })
            .collect();

        // calculate_change
        let mut change_diff = 0;

        for x in 0..self.risk.len() {
            for y in 0..self.risk[0].len() {
                change_diff += new_expected_risk[x][y].unwrap_or(0) as i64
                    - self.expected_risk[x][y].unwrap_or(0) as i64;
            }
        }

        self.expected_risk = new_expected_risk;

        Some(change_diff)
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    const EXAMPLE: &str = "1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581";

    #[test]
    fn test_parse() {
        let map = RiskMap::from_str(EXAMPLE).unwrap();
    }

    #[test]
    fn test_part1() {
        fn new_map() -> RiskMap {
            RiskMap::from_str(EXAMPLE).unwrap()
        }
        assert_eq!(40, new_map().find_cost_map()[0][0] - 1);
    }

    #[test]
    fn test_part2() {
        fn new_map() -> RiskMap {
            RiskMap::from_str(EXAMPLE).unwrap()
        }
        assert_eq!(315, new_map().bigger_risk_map().find_cost_map()[0][0] - 1);
    }
}
