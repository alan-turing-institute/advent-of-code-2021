use itertools::Itertools;
use std::fs;
use std::num::ParseIntError;
use std::str::FromStr;

#[derive(Debug)]
struct HeightMap(Vec<Vec<i32>>);

impl FromStr for HeightMap {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let input: Vec<Vec<i32>> = s
            .lines()
            .map(|line| {
                line.chars()
                    .map(|elem| elem.to_digit(10).unwrap() as i32)
                    .collect()
            })
            .collect();

        Ok(HeightMap(input))
    }
}

impl HeightMap {
    fn find_neighbours_idx(&self, i: usize, j: usize) -> Vec<(usize, usize)> {
        let mut neighbour_idx = Vec::new();

        if i > 0 {
            neighbour_idx.push((i - 1, j));
        }

        if i < self.0.len() - 1 {
            neighbour_idx.push((i + 1, j));
        }

        if j > 0 {
            neighbour_idx.push((i, j - 1));
        }

        if j < self.0[0].len() - 1 {
            neighbour_idx.push((i, j + 1));
        }

        neighbour_idx
    }

    fn find_neighbours(&self, i: usize, j: usize) -> Vec<i32> {
        let ind = self.find_neighbours_idx(i, j);
        ind.iter().map(|(i, j)| self.0[*i][*j]).collect()
    }

    fn find_low_point_idx(&self) -> Vec<(usize, usize)> {
        let mut low_points_idx = Vec::new();

        for i in 0..self.0.len() {
            for j in 0..self.0[0].len() {
                let neighbours = self.find_neighbours(i, j);
                if neighbours.iter().all(|&n| self.0[i][j] < n) {
                    low_points_idx.push((i, j));
                }
            }
        }
        low_points_idx
    }

    fn find_low_points(&self) -> Vec<i32> {
        let low_idx = self.find_low_point_idx();
        low_idx.iter().map(|(i, j)| self.0[*i][*j]).collect()
    }
    
    fn find_basin_members<'a>(
        &self,
        members: &'a mut Vec<(usize, usize)>,
        new_members: &mut Vec<(usize, usize)>,
    ) -> &'a Vec<(usize, usize)> {

        let mut more_members = Vec::new();

        for member in new_members.iter() {
            let neighbours = self.find_neighbours_idx(member.0, member.1);
            let mut in_basin: Vec<_> = neighbours
                .into_iter()
                .filter(|(i, j)| (self.0[*i][*j] - self.0[member.0][member.1]) > 0 && self.0[*i][*j] != 9)
                .collect();
            more_members.append(&mut in_basin);
        }

        members.append(new_members);

        if more_members.is_empty() {
            return members;
        }
        return self.find_basin_members(members, &mut more_members);
    }

    fn find_basin_members_non_recursive(&self, start: (usize, usize)) -> Vec<(usize, usize)> {


        let mut process_members = vec![start];
        let mut all_members = vec![];

        while process_members.len() > 0 {

            let next_member = process_members.pop().unwrap();
            
            let neighbours: Vec<_> = self.find_neighbours_idx(next_member.0, next_member.1);

            let mut in_basin: Vec<_> = neighbours
                    .into_iter()
                    .filter(|(i, j)| ((self.0[*i][*j] - self.0[next_member.0][next_member.1]) > 0) && self.0[*i][*j] != 9)
                    .collect();
   
            process_members.append(&mut in_basin);

            all_members.push(next_member);
        }


        all_members

    }

    // Find all basin sizes
    fn find_basin_size_product(&self, recursive: bool) -> usize {

        let mut all_sizes = Vec::new();
        let low_points = self.find_low_point_idx();

        if recursive {
            for point in low_points {
                let basin: Vec<_> = self.find_basin_members(&mut vec![], &mut vec![point])
                    .into_iter()
                    .unique() // May have duplicates. Remove them.
                    .map(|(i, j)| self.0[*i][*j])
                    .collect();
                all_sizes.push(basin.len());
            }
        } else {
        for point in low_points {
            let basin: Vec<_> = self.find_basin_members_non_recursive(point)
                .into_iter()
                .unique() // May have duplicates. Remove them.
                .map(|(i, j)| self.0[i][j])
                .collect();
            all_sizes.push(basin.len());
        }
    }

        all_sizes.iter().sorted().rev().take(3).product()
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let heights = HeightMap::from_str(&input).unwrap();
    let part1 = heights
        .find_low_points()
        .iter()
        .map(|lp| lp + 1)
        .sum::<i32>();

    println!("Part 1 = {}", part1);
    println!("Part 2 = {}", heights.find_basin_size_product(false));
    println!("Part 2 recursive = {}", heights.find_basin_size_product(true));
}

#[cfg(test)]
mod tests {

    use super::*;

    const EXAMPLE: &str = "2199943210
3987894921
9856789892
8767896789
9899965678";

    #[test]
    fn test_part_1() {
        let heights = HeightMap::from_str(EXAMPLE).unwrap();
        assert_eq!(
            15,
            heights
                .find_low_points()
                .iter()
                .map(|lp| lp + 1)
                .sum::<i32>()
        );
    }

    #[test]
    fn test_part_2() {
        let heights = HeightMap::from_str(EXAMPLE).unwrap();
        assert_eq!(1134, heights.find_basin_size_product(false));
    }
}
