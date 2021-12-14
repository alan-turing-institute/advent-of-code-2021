use std::fmt;
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

        let edge_list: Vec<(CaveType, CaveType)> = lines
            .map(|line| {
                let (parent, child) = line.split_once("-").unwrap();

                // Start must always be a parent
                let (parent, child) = match child {
                    "start" => (child, parent),
                    _ => (parent, child)
                };

                let parent = match parent {
                    "start" => CaveType::Start,
                    "end" => CaveType::End,
                    _ => {
                        let letter = parent.chars().next().unwrap();
                        match letter {
                            'a'..='z' => CaveType::Small(letter),
                            'A'..='Z' => CaveType::Big(letter),
                            _ => panic!("Cant parse"),
                        }
                    }
                };

                let child = match child {
                    "start" => CaveType::Start,
                    "end" => CaveType::End,
                    _ => {
                        let letter = child.chars().next().unwrap();
                        match letter {
                            'a'..='z' => CaveType::Small(letter),
                            'A'..='Z' => CaveType::Big(letter),
                            _ => panic!("Cant parse"),
                        }
                    }
                };
                (parent, child)
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
    fn bfs(&self) -> Vec<Vec<CaveType>> {

        let mut all_valid_paths = Vec::new();
        let mut queue: VecDeque<(Vec<CaveType>, Rc<RefCell<Cave>>)> = VecDeque::new();

        queue.push_back((Vec::new(), Rc::clone(&self.root)));

        while queue.len() > 0 {

            println!("Len = {}", queue.len());

            let (mut path, node) = queue.pop_front().unwrap();
            let node = node.borrow();

            match node.name {
                CaveType::End => {
                    all_valid_paths.push(path); 
                },
                CaveType::Small(c) if path.iter().filter(|&x| x == &CaveType::Small(c)).count() >= 1 => {
                    println!("Been here, {:?}", node.name);
                },  
                _ => {
                    println!("parent, {:?}", node.name);
                    for child in node.children.iter() {
                        println!("child, {:?}", child.borrow().name);
                        let mut path_copy = path.clone();
                        path_copy.push(node.name);
                        queue.push_back((path_copy, Rc::clone(child)));
                    }
                }
            };
        }

        all_valid_paths
    }
}

fn main() {
    println!("Hello, world!");
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
        assert_eq!(10,  CaveSystem::from_str(EXAMPLE).unwrap().bfs().len());
        assert_eq!(19,  CaveSystem::from_str(EXAMPLE_2).unwrap().bfs().len());
    }

    #[test]
    fn test_caves() {
        assert_eq!(CaveType::Start, CaveType::Start);
        assert_eq!(CaveType::End, CaveType::End);
        assert_eq!(CaveType::Small('a'), CaveType::Small('a'));

        assert!(vec![CaveType::Small('a'), CaveType::Small('b'), CaveType::Small('c')].iter().filter(|&x| x == &CaveType::Small('a')).count() >= 1);
        assert!(vec![CaveType::Small('a'), CaveType::Small('b'), CaveType::Small('c')].iter().filter(|&x| x == &CaveType::Small('b')).count() >= 1);
        assert!(vec![CaveType::Small('a'), CaveType::Small('b'), CaveType::Small('c')].iter().filter(|&x| x == &CaveType::Small('c')).count() >= 1);
        assert!(!(vec![CaveType::Small('a'), CaveType::Small('b'), CaveType::Small('c')].iter().filter(|&x| x == &CaveType::Small('d')).count() >= 1));
    }



}
