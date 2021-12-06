use std::fs;

#[derive(Debug, PartialEq)]
struct Lantern {
    fish: [u64; 9],
}

impl Lantern {
    fn new(fish_cycle: &Vec<u64>) -> Self {
        let mut first_day: [u64; 9] = [0; 9];

        for fish in fish_cycle.iter().map(|&fish| fish as usize) {
            first_day[fish - 1] += 1;
        }

        Self { fish: first_day }
    }
}

impl Iterator for Lantern {
    type Item = [u64; 9];

    fn next(&mut self) -> Option<Self::Item> {
        let mut next_day: [u64; 9] = [0; 9];
        for i in 0..8 {
            next_day[i] = self.fish[i + 1];
        }

        next_day[8] = self.fish[0];
        next_day[6] += self.fish[0];

        self.fish = next_day;

        return Some(self.fish);
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let input: Vec<u64> = input
        .lines()
        .next()
        .unwrap()
        .split(",")
        .map(|x| x.parse::<u64>().unwrap())
        .collect();

    let part1: u64 = Lantern::new(&input).nth(80 - 2).unwrap().iter().sum();
    let part2: u64 = Lantern::new(&input).nth(256 - 2).unwrap().iter().sum();

    println!("Part 1 = {}", part1);
    println!("Part 2 = {}", part2);
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_fish() {
        assert_eq!(
            26,
            Lantern {
                fish: [1, 1, 2, 1, 0, 0, 0, 0, 0]
            }
            .nth(18 - 2)
            .unwrap()
            .iter()
            .sum::<u64>()
        );
        assert_eq!(
            5934,
            Lantern {
                fish: [1, 1, 2, 1, 0, 0, 0, 0, 0]
            }
            .nth(80 - 2)
            .unwrap()
            .iter()
            .sum::<u64>()
        );

        assert_eq!(
            26984457539,
            Lantern {
                fish: [1, 1, 2, 1, 0, 0, 0, 0, 0]
            }
            .nth(256 - 2)
            .unwrap()
            .iter()
            .sum::<u64>()
        );
    }

    #[test]
    fn test_new_fish() {
        assert_eq!(
            Lantern::new(&vec![3, 4, 3, 1, 2]),
            Lantern {
                fish: [1, 1, 2, 1, 0, 0, 0, 0, 0]
            }
        );
    }
}
