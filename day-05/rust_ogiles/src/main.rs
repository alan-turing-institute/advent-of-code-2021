use lazy_static::lazy_static;
use regex::Regex;
use std::fs;
use std::{cmp, collections::HashMap, ops::Sub};

#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
struct Point(i32, i32);

impl Sub for Point {
    type Output = Self;

    fn sub(self, other: Self) -> Self::Output {
        Self {
            0: self.0 - other.0,
            1: self.1 - other.1,
        }
    }
}

#[derive(Debug, Copy, Clone, PartialEq)]
struct Line {
    start: Point,
    end: Point,
}

impl Line {
    fn new(start: Point, end: Point) -> Self {
        Self { start, end }
    }

    /// Parse a &str of the form "0,9 -> 5,9" into a Line
    fn from_str(input: &str) -> Self {
        // Avoid recompilation of Regex, which is slow.
        // lazy_static evaluates an expression once and then uses cached value.
        lazy_static! {
            static ref RE: Regex = Regex::new(r"([\d]+),([\d]+) -> ([\d]+),([\d]+)").unwrap();
        }

        let cap = RE.captures(input).unwrap();

        Self::new(
            Point(cap[1].parse().unwrap(), cap[2].parse().unwrap()),
            Point(cap[3].parse().unwrap(), cap[4].parse().unwrap()),
        )
    }

    /// Get all the points on a horizontal or vertical line.
    /// If diagonal line return None
    fn points_on_line(&self, diagonal: bool) -> Option<Vec<Point>> {
        match self.end - self.start {
            Point(0, _) => {
                let start = cmp::min(self.start.1, self.end.1);
                let end = cmp::max(self.start.1, self.end.1);
                return Some(
                    (start..=end)
                        .map(|y| Point(self.start.0, y))
                        .collect::<Vec<Point>>(),
                );
            }
            Point(_, 0) => {
                let start = cmp::min(self.start.0, self.end.0);
                let end = cmp::max(self.start.0, self.end.0);
                return Some(
                    (start..=end)
                        .map(|x| Point(x, self.start.1))
                        .collect::<Vec<Point>>(),
                );
            }
            _ => {
                //Implement diagonal line
                None
            }
        }
    }
}

fn part1(input: &Vec<Line>) -> usize {
    let mut counter: HashMap<Point, i32> = HashMap::new();
    input.iter().for_each(|line| {
        let points = line.points_on_line(false);

        if let Some(point) = points {
            point.iter().for_each(|&p| {
                let count = counter.entry(p).or_insert(0);
                *count += 1;
            })
        }
    });

    counter.values().filter(|&val| val > &1).count() as usize
}

fn main() {
    println!("Hello, world!");

    let input = fs::read_to_string("input.txt").unwrap();

    let all_line: Vec<Line> = input.lines().map(|line| Line::from_str(line)).collect();

    println!("Part 1 = {}", part1(&all_line));
}

#[cfg(test)]
mod tests {

    use super::*;

    const EXAMPLE_INPUT: &str = "0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
";

    #[test]
    fn test_point_on_line() {
        let line = Line::new(Point(0, 1), Point(0, 3)).points_on_line(false);
        assert_eq!(Some(vec![Point(0, 1), Point(0, 2), Point(0, 3)]), line);

        let line = Line::new(Point(3, 15), Point(5, 15)).points_on_line(false);
        assert_eq!(Some(vec![Point(3, 15), Point(4, 15), Point(5, 15)]), line);

        let line = Line::new(Point(5, 15), Point(3, 15)).points_on_line(false);
        assert_eq!(Some(vec![Point(3, 15), Point(4, 15), Point(5, 15)]), line);

        let line = Line::new(Point(0, 0), Point(3, 3)).points_on_line(false);
        assert_eq!(None, line);
    }

    #[test]
    fn test_line_parser() {
        assert_eq!(
            Line::from_str("0,9 -> 5,9"),
            Line::new(Point(0, 9), Point(5, 9))
        );
    }

    #[test]
    fn test_part_1s() {
        let input: Vec<Line> = EXAMPLE_INPUT
            .lines()
            .map(|line| Line::from_str(line))
            .collect();
        assert_eq!(part1(&input), 5);
    }
}
