use std::{num::ParseIntError, str::FromStr};

fn main() {
    println!("Hello, world!");
}

#[derive(Debug)]
struct Tree {
    value: Vec<Num>,
}

impl Tree {
    fn new(tree: Vec<Num>) -> Self {
        Self { value: tree }
    }
    fn get_num(&self, idx: usize) -> &Num {
        &self.value[idx]
    }
    fn right_num(&self, idx: usize) -> &Num {
        self.get_num(self.get_num(idx).unwrap_snailtree().right.unwrap())
    }
    fn left_num(&self, idx: usize) -> &Num {
        self.get_num(self.get_num(idx).unwrap_snailtree().left.unwrap())
    }
    fn walk_tree(&self) -> Option<usize> {
        // Find nodes at depth 3 (nested in 4 brackets)
        // Explode the left node
        let mut stack = vec![&self.value[0]];

        while stack.len() > 0 {
            let node = stack.pop()?;
            match node {
                Num::Regular(literal) => {
                    println!("val = {}", literal);
                }
                Num::Pair(tree_node) => {
                    if tree_node.depth == 3 {
                        // return Some(tree_node.left?);
                    }
                    stack.push(&self.value[tree_node.right?]);
                    stack.push(&self.value[tree_node.left?]);
                    
                }
            };
        }
        None
    }

    fn first_right_reg_idx(&self, num: &Num) -> Option<usize> {
        let mut parent = num.unwrap_snailtree().parent;

        while parent.is_some() {
            let right = self.right_num(parent?);
            if let Num::Regular(_) = right {
                return Some(self.get_num(parent?).unwrap_snailtree().right?);
            }
            parent = self.get_num(parent?).unwrap_snailtree().parent;
        }

        None
    }

    fn first_left_reg_idx(&self, num: &Num) -> Option<usize> {
        let mut parent = num.unwrap_snailtree().parent;

        while parent.is_some() {
            let left = self.left_num(parent?);

            if let Num::Regular(_) = left {
                return Some(self.get_num(parent?).unwrap_snailtree().left?);
            }

            parent = self.get_num(parent?).unwrap_snailtree().parent;
        }

        None
    }

    fn explode(&mut self, explode_idx: usize) {
        let value_to_explode = self.get_num(explode_idx);

        if let &Num::Pair(p) = value_to_explode {
            let left = self.get_num(p.left.unwrap()).unwrap_regular();
            let right = self.get_num(p.right.unwrap()).unwrap_regular();

            let first_right = self.first_right_reg_idx(value_to_explode);
            let first_left = self.first_left_reg_idx(value_to_explode);

            if let Some(r) = first_right {
                self.value[r] = Num::Regular(self.value[r].unwrap_regular() + right)
            }

            if let Some(l) = first_left {
                self.value[l] = Num::Regular(self.value[l].unwrap_regular() + left)
            }
            self.value[explode_idx] = Num::Regular(0);
            self.value.remove(p.left.unwrap());
            self.value.remove(p.right.unwrap());
        }
    }
}
impl FromStr for Tree {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut value: Vec<Num> = vec![];
        let mut stack: Vec<usize> = vec![];

        for i in 0..s.len() {
            let c = &s[i..i + 1];

            match c {
                "[" => {
                    let p = Num::Pair(SnailTree::new(None, None, None, 0));

                    let tree_size = value.len();

                    if tree_size > 0 {
                        let last_pair_idx = stack.len() - 1;
                        let last_pair = &mut value[stack[last_pair_idx]];

                        if last_pair.unwrap_snailtree().left.is_none() {
                            if let Num::Pair(v) = last_pair {
                                v.left = Some(tree_size);
                            }
                        } else {
                            if let Num::Pair(v) = last_pair {
                                v.right = Some(tree_size);
                            }
                        }
                    }

                    value.push(p);
                    stack.push(value.len() - 1);
                }
                "," => {}
                "]" => {
                    stack.pop();
                }
                _ => {
                    let mut longer_c = &s[i..i + 2];
                    if longer_c.contains(",") | longer_c.contains("]") {
                        longer_c = c;
                    }
                    let last_pair_idx = stack.len() - 1;
                    let tree_size = value.len();
                    let last_pair = &mut value[stack[last_pair_idx]];

                    if last_pair.unwrap_snailtree().left.is_none() {
                        if let Num::Pair(v) = last_pair {
                            v.left = Some(tree_size);
                        }
                    } else {
                        if let Num::Pair(v) = last_pair {
                            v.right = Some(tree_size);
                        }
                    }

                    value.push(Num::Regular(longer_c.parse::<u8>().unwrap()));
                }
            }
        }

        // for c in s.chars() {

        Ok(Tree { value: value })
    }
}

#[derive(Debug, Clone, Copy)]
struct SnailTree {
    parent: Option<usize>,
    left: Option<usize>,
    right: Option<usize>,
    depth: u8,
}

impl SnailTree {
    fn new(parent: Option<usize>, left: Option<usize>, right: Option<usize>, depth: u8) -> Self {
        Self {
            parent,
            left,
            right,
            depth,
        }
    }
}

#[derive(Debug, Clone, Copy)]
enum Num {
    Regular(u8),
    Pair(SnailTree),
}

impl Num {
    fn unwrap_regular(&self) -> u8 {
        match self {
            Num::Regular(reg) => *reg,
            _ => panic!("Not regular"),
        }
    }

    fn unwrap_snailtree(&self) -> SnailTree {
        match self {
            Num::Regular(_) => panic!("Not a SnailTree"),
            Num::Pair(pair) => *pair,
        }
    }
}

// 1. Add SnailNum by placing in a pair
// SnailNum must always be reduced.
// To reduce repeatedly do the first action in this list that applies to the snailfish number:
//      1. If any pair is nested inside four pairs, the leftmost such pair explodes.
//      2. If any regular number is 10 or greater, the leftmost such regular number splits.
//   If none of the above apply it is reduced.

// To explode a pair, the pair's left value is added to the first regular number to the left of the exploding pair (if any),
// and the pair's right value is added to the first regular number to the right of the exploding pair (if any).
// Exploding pairs will always consist of two regular numbers. Then, the entire exploding pair is replaced with the regular number 0.

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test() {
        // [[[[[9,8],1],2],3],4]

        let t = vec![
            Num::Pair(SnailTree::new(None, Some(2), Some(1), 0)),
            Num::Regular(4),
            Num::Pair(SnailTree::new(Some(0), Some(4), Some(3), 1)),
            Num::Regular(3),
            Num::Pair(SnailTree::new(Some(2), Some(6), Some(5), 2)),
            Num::Regular(2),
            Num::Pair(SnailTree::new(Some(4), Some(8), Some(7), 3)),
            Num::Regular(1),
            Num::Pair(SnailTree::new(Some(6), Some(9), Some(10), 4)),
            Num::Regular(9),
            Num::Regular(8),
        ];

        let mut tree = Tree::new(t);

        println!("{:?}", tree.value);

        tree.walk_tree();
        // tree.explode(tree.walk_tree().unwrap());

        // println!("{:?}", tree.value);
    }

    #[test]
    fn test_parse() {
        let s = "[[[[[9,8],1],2],3],4]";

        let tree = Tree::from_str(s).unwrap();

        println!("{:?}", tree.value);

        tree.walk_tree();
    }
}
