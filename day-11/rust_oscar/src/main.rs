use std::num::ParseIntError;
use std::str::FromStr;

#[derive(Debug)]
struct Octopus {
    energy: u32,
    flashed: bool,
}

impl Octopus {
    fn new(energy: u32) -> Self {
        Self {
            energy,
            flashed: false,
        }
    }
}

#[derive(Debug)]
struct Octopi {
    octopi: Vec<Vec<Octopus>>,
    flashes: u32,
}

impl Octopi {
    fn size(&self) -> usize {
        self.octopi.len() * self.octopi[0].len()
    }
    fn find_neighbours(&self, pos: (usize, usize)) -> Vec<(usize, usize)> {
        let pos = (pos.0 as i32, pos.1 as i32);
        let offsets = [
            (-1, -1),
            (-1, 0),
            (-1, 1),
            (0, -1),
            (0, 1),
            (1, -1),
            (1, 0),
            (1, 1),
        ];

        let neighbours = offsets
            .iter()
            .map(|off| (pos.0 + off.0, pos.1 + off.1))
            .filter(|neighbour| {
                neighbour.0 >= 0
                    && neighbour.0 < self.octopi.len() as i32
                    && neighbour.1 >= 0
                    && neighbour.1 < self.octopi[0].len() as i32
            })
            .map(|neighbour| (neighbour.0 as usize, neighbour.1 as usize))
            .collect();

        neighbours
    }
}

impl Iterator for Octopi {
    type Item = (u32, u32);

    fn next(&mut self) -> Option<Self::Item> {
        let previous_flashes = self.flashes;

        // Increase all energy by 1. None should flash yet
        for i in 0..self.octopi.len() {
            for j in 0..self.octopi[0].len() {
                let oct = &mut self.octopi[i][j];
                oct.energy += 1;
            }
        }

        // Find any with energy > 9. Put onto stack, find neighbours, add 1, repeat
        let mut stack = Vec::new();

        loop {
            for i in 0..self.octopi.len() {
                for j in 0..self.octopi[0].len() {
                    let oct = &mut self.octopi[i][j];
                    if oct.energy > 9 && oct.flashed == false {
                        stack.push((i, j));
                        self.flashes += 1;
                        oct.flashed = true;
                    }
                }
            }

            // Process the stack
            match stack.len() {
                0 => {
                    for i in 0..self.octopi.len() {
                        for j in 0..self.octopi[0].len() {
                            let oct = &mut self.octopi[i][j];
                            if oct.energy > 9 {
                                oct.flashed = false;
                                oct.energy = 0;
                            }
                        }
                    }

                    return Some((self.flashes, self.flashes - previous_flashes));
                }
                _ => {
                    while stack.len() > 0 {
                        let oct_idx = stack.pop().unwrap();
                        let neighbours = self.find_neighbours(oct_idx);

                        for (i, j) in neighbours {
                            let oct = &mut self.octopi[i][j];
                            oct.energy += 1;
                        }
                    }
                }
            };
        }
    }
}

impl FromStr for Octopi {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let input: Vec<Vec<Octopus>> = s
            .lines()
            .map(|line| {
                line.chars()
                    .map(|elem| Octopus::new(elem.to_digit(10).unwrap() as u32))
                    .collect()
            })
            .collect();

        Ok(Octopi {
            octopi: input,
            flashes: 0,
        })
    }
}

fn main() {
    let input = "4871252763
8533428173
7182186813
2128441541
3722272272
8751683443
3135571153
5816321572
2651347271
7788154252";

    let part1 = Octopi::from_str(input).unwrap().nth(100 - 1).unwrap();

    let mut all_octopus = Octopi::from_str(input).unwrap();
    let size = all_octopus.size();
    let part2 = all_octopus
        .enumerate()
        .take_while(|(_, (_, flash))| *flash != size as u32)
        .last();

    println!("Part 1 = {}", part1.0);
    println!("Part 2 = {:?}", part2.unwrap().0 + 2);
}

#[cfg(test)]
mod tests {

    use super::*;

    const EXAMPLE: &str = "5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526";

    #[test]
    fn test_part_1() {
        let mut ans = Octopi::from_str(EXAMPLE).unwrap();
        assert_eq!(1656, ans.nth(100 - 1).unwrap().0);
    }

    #[test]
    fn test_part_2() {
        let mut all_octopus = Octopi::from_str(EXAMPLE).unwrap();
        let size = all_octopus.size();
        let part2 = all_octopus
            .enumerate()
            .take_while(|(_, (_, flash))| *flash != size as u32)
            .last();
        assert_eq!(195, part2.unwrap().0 + 2);
    }
}
