use itertools::Itertools;
use std::fs;

#[derive(Debug)]
struct Error;

struct Report(Vec<Vec<u32>>);

impl Report {
    fn new(input: &str) -> Self {
        Self(
            input
                .lines()
                .map(|row| {
                    row.chars()
                        .map(|x| x.to_digit(10).unwrap())
                        .collect::<Vec<u32>>()
                })
                .collect(),
        )
    }

    fn most_common_bit(matrix: &Vec<Vec<u32>>, col: usize) -> u32 {

        let mut total_1: u32 = 0;
        let mut total_0: u32 = 0;

        for row in 0..matrix.len() {
            
            if matrix[row][col] == 1 {
                total_1 +=1;
            } else {
                total_0 += 1;
            }
        }

        if total_0 > total_1 {
            0
        }
        else {
            1
        }

    }

    fn least_common_bit(matrix: &Vec<Vec<u32>>, col: usize) -> u32 {
        if Report::most_common_bit(matrix, col) == 0 {
            1
        } else {
            0
        }
    }

    fn n_cols(&self) -> usize {
        self.0[0].len()
    }

    fn bits_to_num(bit_vec: &Vec<u32>) -> u32 {
        u32::from_str_radix(&bit_vec.iter().join(""), 2).unwrap()
    }

    fn gamma_rate(&self) -> u32 {
        let mut gamma_rate_vec: Vec<u32> = vec![0; self.n_cols()];

        for col in 0..self.n_cols() {
            gamma_rate_vec[col] += Report::most_common_bit(&self.0, col);
        }

        Self::bits_to_num(&gamma_rate_vec)
    }

    fn delta_rate(&self) -> u32 {

        let mut delta_rate_vec: Vec<u32> = vec![0; self.n_cols()];

        for col in 0..self.n_cols() {
            delta_rate_vec[col] += Report::least_common_bit(&self.0, col);
        }

        Self::bits_to_num(&delta_rate_vec)
    }

    fn oxygen_generator_rating(&self) -> Result<u32, Error> {

        let mut res = self.0.clone();

        for col in 0..self.n_cols() {
            let mcb = Report::most_common_bit(&res, col);
            res = res.into_iter().filter(|x| x[col] == mcb).collect();

            if res.len() == 1 {
                return Ok(Self::bits_to_num(&res[0]))
            }
        }

        Err(Error)
    }

    fn co2_scrubber_rating(&self) -> Result<u32, Error> {

        let mut res = self.0.clone();

        for col in 0..self.n_cols() {
            let mcb = Report::least_common_bit(&res, col);
            res = res.into_iter().filter(|x| x[col] == mcb).collect();

            if res.len() == 1 {
                return Ok(Self::bits_to_num(&res[0]))
            }
        }

        Err(Error)
    }

}

fn part1(input: &str) -> u32 {
    let my_report = Report::new(input);
    my_report.delta_rate() * my_report.gamma_rate()
}

fn part2(input: &str) -> u32 {
    let my_report = Report::new(input);
    my_report.oxygen_generator_rating().unwrap() * my_report.co2_scrubber_rating().unwrap()
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    println!("Part 1 = {}", part1(&input));
    println!("Part 3 = {}", part2(&input));
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXAMPLE: &str = "00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010";

    #[test]
    fn test_part_1() {
        assert_eq!(part1(EXAMPLE), 198);
    }

    #[test]
    fn test_part_2() {
        assert_eq!(part2(EXAMPLE), 230);
    }


}
