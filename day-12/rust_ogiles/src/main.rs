use std::fmt;
use std::fs;
use std::ops::RangeInclusive;
use std::{
    cell::RefCell,
    collections::{HashMap, VecDeque},
    hash::{Hash, Hasher},
    rc::Rc,
    str::FromStr,
};

#[derive(Debug)]
struct ParseCaveError;

#[derive(PartialEq, Eq)]
struct Cave {
    name: CaveType,
    children: Vec<Rc<RefCell<Cave>>>,
}

impl fmt::Display for Cave {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "name: {:?}, children: {:?}",
            self.name,
            self.children
                .iter()
                .map(|c| c.borrow().name)
                .collect::<Vec<_>>()
        )
    }
}

impl Hash for Cave {
    fn hash<H: Hasher>(&self, state: &mut H) {
        self.name.hash(state);
    }
}

impl Cave {
    fn new(name: CaveType) -> Self {
        Self {
            name,
            children: Vec::new(),
        }
    }
}

#[derive(PartialEq, Eq, Hash, Clone, Copy, Debug)]
enum CaveType {
    Start,
    Small(char),
    Big(char),
    End,
}

struct CaveSystem {
    root: Rc<RefCell<Cave>>,
}

impl FromStr for CaveSystem {
    type Err = ParseCaveError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let lines = s.lines();
        let mut charmap = HashMap::new();
        let mut all_chars = 0..=1000;

        let edge_list: Vec<(CaveType, CaveType)> = lines
            .map(|line| {
                let (parent, child) = line.split_once("-").unwrap();

                // Start must always be a parent
                let (parent, child) = match child {
                    "start" => (child, parent),
                    _ => (parent, child),
                };

                // Convert input to a char to avoid lifetime issues
                let mut get_cave_type = |v, all_chars: &mut RangeInclusive<u32>| match v {
                    "start" => CaveType::Start,
                    "end" => CaveType::End,
                    _ => {
                        let letter = charmap
                            .entry(v)
                            .or_insert(char::from_u32(all_chars.next().unwrap()).unwrap());

                        if v.to_uppercase() == v {
                            CaveType::Big(*letter)
                        } else {
                            CaveType::Small(*letter)
                        }
                    }
                };

                (
                    get_cave_type(parent, &mut all_chars),
                    get_cave_type(child, &mut all_chars),
                )
            })
            .collect();

        let mut all_caves = HashMap::new();

        // Create a HashMap of all caves
        for (parent, child) in edge_list {
            let parent_cave = match all_caves.get(&parent) {
                Some(cave) => Rc::clone(cave),
                None => {
                    let cave = Rc::new(RefCell::new(Cave::new(parent)));
                    all_caves.insert(parent, Rc::clone(&cave));
                    cave
                }
            };

            let child_cave = match all_caves.get(&child) {
                Some(cave) => Rc::clone(cave),
                None => {
                    let cave = Rc::new(RefCell::new(Cave::new(child)));
                    all_caves.insert(child, Rc::clone(&cave));
                    cave
                }
            };

            parent_cave
                .borrow_mut()
                .children
                .push(Rc::clone(&child_cave));

            if parent != CaveType::Start {
                child_cave.borrow_mut().children.push(parent_cave);
            }
        }

        let root = all_caves.get(&CaveType::Start).unwrap();

        Ok(Self {
            root: Rc::clone(root),
        })
    }
}

impl CaveSystem {
    fn bfs(&self, double: bool) -> Vec<Vec<CaveType>> {
        let mut all_valid_paths = Vec::new();
        let mut queue: VecDeque<(Vec<CaveType>, Rc<RefCell<Cave>>, bool)> = VecDeque::new();

        queue.push_back((Vec::new(), Rc::clone(&self.root), false));

        // Visit one small cave twice (optionally visit one small cave twice)
        while queue.len() > 0 {
            let (path, node, mut double_cave) = queue.pop_front().unwrap();
            let node = node.borrow();

            match node.name {
                CaveType::End => {
                    all_valid_paths.push(path);
                }

                CaveType::Small(c)
                    if path.iter().filter(|&x| x == &CaveType::Small(c)).count() >= 1 && ( !double || double_cave)
                    => {}
                _ => {

                    if let CaveType::Small(c) = node.name {
                        if path.iter().filter(|&x| x == &CaveType::Small(c)).count() >= 1 {
                            double_cave = true;
                        }
                    }
                    for child in node.children.iter() {
                        let mut path_copy = path.clone();
                        path_copy.push(node.name);
                        queue.push_back((path_copy, Rc::clone(child), double_cave));
                    }
                }
            };
        }

        all_valid_paths
    }
}

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();
    let caves = CaveSystem::from_str(&input).unwrap();
    println!("Part 1 = {}", caves.bfs(false).len());
    println!("Part 2 = {}", caves.bfs(true).len());
}

#[cfg(test)]
mod tests {
    use std::str::FromStr;

    use crate::{CaveSystem, CaveType};

    const EXAMPLE: &str = "start-A
start-b
A-c
A-b
b-d
A-end
b-end";

    const EXAMPLE_2: &str = "d-end
H-start
start-k
d-start
d-H
L-d
H-end
k-s
k-H
k-d";

    #[test]
    fn test_graph_from_str() {
        let cave_system = CaveSystem::from_str(EXAMPLE).unwrap();

        let root = cave_system.root;

        println!("Root: {}", root.borrow());
        println!("Child 1: {}", root.borrow().children[0].borrow());
        println!("Child 2: {}", root.borrow().children[1].borrow());
    }

    #[test]
    fn test_bfs() {
        assert_eq!(10, CaveSystem::from_str(EXAMPLE).unwrap().bfs(false).len());
        assert_eq!(19, CaveSystem::from_str(EXAMPLE_2).unwrap().bfs(false).len());
    }

    #[test]
    fn test_bfs_2() {
        assert_eq!(36,  CaveSystem::from_str(EXAMPLE).unwrap().bfs(true).len());
        assert_eq!(103, CaveSystem::from_str(EXAMPLE_2).unwrap().bfs(true).len());
    }

    #[test]
    fn test_caves() {
        assert_eq!(CaveType::Start, CaveType::Start);
        assert_eq!(CaveType::End, CaveType::End);
        assert_eq!(CaveType::Small('a'), CaveType::Small('a'));

        assert!(
            vec![
                CaveType::Small('a'),
                CaveType::Small('b'),
                CaveType::Small('c')
            ]
            .iter()
            .filter(|&x| x == &CaveType::Small('a'))
            .count()
                >= 1
        );
        assert!(
            vec![
                CaveType::Small('a'),
                CaveType::Small('b'),
                CaveType::Small('c')
            ]
            .iter()
            .filter(|&x| x == &CaveType::Small('b'))
            .count()
                >= 1
        );
        assert!(
            vec![
                CaveType::Small('a'),
                CaveType::Small('b'),
                CaveType::Small('c')
            ]
            .iter()
            .filter(|&x| x == &CaveType::Small('c'))
            .count()
                >= 1
        );
        assert!(
            !(vec![
                CaveType::Small('a'),
                CaveType::Small('b'),
                CaveType::Small('c')
            ]
            .iter()
            .filter(|&x| x == &CaveType::Small('d'))
            .count()
                >= 1)
        );
    }
}
