use std::{fs, num::ParseIntError, str::FromStr};

use itertools::Itertools;

#[derive(Debug, PartialEq, Eq, Clone, Copy, Hash)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }

    fn fold_x(&self, point: i32) -> Self {
        Self {
            x: -(self.x - point) + point,
            y: self.y,
        }
    }

    fn fold_y(&self, point: i32) -> Self {
        Self {
            x: self.x,
            y: -(self.y - point) + point,
        }
    }
}

#[derive(Debug)]
enum Fold {
    Up(i32),
    Left(i32),
}

#[derive(Debug)]
struct Origami {
    points: Vec<Point>,
    instructions: Vec<Fold>,
}

impl Origami {
    fn work(&self, u: usize) -> Vec<Point> {
        self.instructions
            .iter()
            .take(u)
            .fold(self.points.clone(), |acc, instr| match instr {
                Fold::Up(val) => acc
                    .iter()
                    .filter(|&p| p.y > *val)
                    .map(|p| p.fold_y(*val))
                    .chain(acc.iter().filter(|&p| p.y < *val).map(|p| *p))
                    .unique()
                    .collect(),

                Fold::Left(val) => acc
                    .iter()
                    .filter(|&p| p.x > *val)
                    .map(|p| p.fold_x(*val))
                    .chain(acc.iter().filter(|&p| p.x < *val).map(|p| *p))
                    .unique()
                    .collect(),
            })
    }
}
impl FromStr for Origami {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (point_str, instructions) = s.split_once("\n\n").unwrap();

        let points = point_str
            .lines()
            .map(|line| {
                let (x, y) = line.split_once(",").unwrap();

                Point::new(x.parse::<i32>().unwrap(), y.parse::<i32>().unwrap())
            })
            .collect();

        let instructions: Vec<Fold> = instructions
            .lines()
            .map(|instruct| {
                let val = instruct.split_once("=").unwrap().1.parse::<i32>().unwrap();
                if instruct.contains('y') {
                    Fold::Up(val)
                } else {
                    Fold::Left(val)
                }
            })
            .collect();

        Ok(Self {
            points,
            instructions,
        })
    }
}

fn print_points(points: &[Point]) {
    let max_x = points.iter().map(|p| p.x).max().unwrap();
    let max_y = points.iter().map(|p| p.y).max().unwrap();

    let mut container = (0..=max_y)
        .map(|_| (0..=max_x).map(|_| '.').collect::<Vec<char>>())
        .collect::<Vec<Vec<char>>>();

    for point in points {
        container[point.y as usize][point.x as usize] = '#';
    }

    let pattern = container
        .iter()
        .map(|y| y.iter().collect::<String>())
        .collect::<Vec<_>>()
        .join("\n");

    println!("{}", pattern);
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let origami = Origami::from_str(&input).unwrap();

    let part1 = origami.work(1).len();

    println!("Part 1 = {}", part1);
    print_points(&origami.work(origami.instructions.len()));
}

#[cfg(test)]
mod tests {

    use super::*;

    const EXAMPLE: &str = "6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5";

    #[test]
    fn test_parse() {
        println!("{:?}", Origami::from_str(EXAMPLE).unwrap().points);
    }

    #[test]
    fn test_reflect() {
        assert_eq!(Point::new(0, 0), Point::new(0, 14).fold_y(7));
        assert_eq!(Point::new(0, 1), Point::new(0, 13).fold_y(7));
        assert_eq!(Point::new(3, 6), Point::new(3, 8).fold_y(7));
        assert_eq!(Point::new(4, 0), Point::new(6, 0).fold_x(5));
    }

    #[test]
    fn test_origami() {
        let origami = Origami::from_str(EXAMPLE).unwrap();

        assert_eq!(origami.work(1).len(), 17);
    }
}
