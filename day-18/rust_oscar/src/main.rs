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
    fn get(&self, idx: usize) -> Option<&Num> {
        self.value.get(idx)
    }
    fn right(&self, idx: usize) -> Option<&Num> {
        self.get(self.get(idx).unwrap().unwrap_snailtree().right)
    }
    fn left(&self, idx: usize) -> Option<&Num> {
        self.get(self.get(idx).unwrap().unwrap_snailtree().left)
    }
    fn walk_tree(&self) -> Option<usize> {
        // Find nodes at depth 3 (nested in 4 brackets)
        // Explode the left node
        let mut stack = vec![&self.value[0]];

        while stack.len() > 0 {
            let node = stack.pop().unwrap();
            match node {
                Num::Regular(literal) => {
                    println!("val = {}", literal);
                }
                Num::Pair(tree_node) => {
                    if tree_node.depth == 3 {
                        return Some(tree_node.left);
                    }
                    stack.push(&self.value[tree_node.left]);
                    stack.push(&self.value[tree_node.right]);
                }
            };
        }
        None
    }

    fn first_right(&self, num: &Num) -> Option<usize> {
        let mut parent = num.unwrap_snailtree().parent;

        while parent.is_some() {
            let right = self.right(parent.unwrap());

            match right {
                Some(right) => {
                    if let Num::Regular(_) = right {
                        return Some(self.get(parent.unwrap()).unwrap().unwrap_snailtree().right);
                    }
                }
                None => {}
            }

            parent = self.get(parent.unwrap()).unwrap().unwrap_snailtree().parent;
        }

        None
    }

    fn first_left(&self, num: &Num) -> Option<usize> {
        let mut parent = num.unwrap_snailtree().parent;

        while parent.is_some() {
            let left = self.left(parent.unwrap());

            match left {
                Some(left) => {
                    if let Num::Regular(_) = left {
                        return Some(self.get(parent.unwrap()).unwrap().unwrap_snailtree().left);
                    }
                }
                None => {}
            }
            parent = self.get(parent.unwrap()).unwrap().unwrap_snailtree().parent;
        }

        None
    }

    fn explode(&mut self, explode_idx: usize) {
        let value_to_explode = self.get(explode_idx).unwrap();

        if let &Num::Pair(p) = value_to_explode {
            let left = self.get(p.left).unwrap().unwrap_regular();
            let right = self.get(p.right).unwrap().unwrap_regular();

            let first_right = self.first_right(value_to_explode);
            let first_left = self.first_left(value_to_explode);

            if let Some(r) = first_right {
                self.value[r] = Num::Regular(self.value[r].unwrap_regular() + right)
            }

            if let Some(l) = first_left {
                self.value[l] = Num::Regular(self.value[l].unwrap_regular() + left)
            }
            self.value[explode_idx] = Num::Regular(0);
            self.value.remove(p.left);
            self.value.remove(p.right);
        }
    }
}

#[derive(Debug, Clone, Copy)]
struct SnailTree {
    parent: Option<usize>,
    left: usize,
    right: usize,
    depth: u8,
}

impl SnailTree {
    fn new(parent: Option<usize>, left: usize, right: usize, depth: u8) -> Self {
        Self {
            parent,
            left,
            right,
            depth,
        }
    }

    // fn walk_tree(&self) {
    //     // Find nodes at depth 3 (nested in 4 brackets)
    //     // Explode the left node
    //     let mut stack = vec![self];

    //     while stack.len() > 0 {
    //         let node = stack.pop().unwrap();

    //         match &*node.left {
    //             Num::Regular(_) => {}
    //             Num::Pair(next_pair) => {
    //                 stack.push(next_pair);
    //             }
    //         };

    //         match &*node.right {
    //             Num::Regular(_) => {}
    //             Num::Pair(next_pair) => {
    //                 stack.push(next_pair);
    //             }
    //         };
    //     }
    // }

    // fn explode(&self) {}
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
            Num::Pair(SnailTree::new(None, 2, 1, 0)),
            Num::Regular(4),
            Num::Pair(SnailTree::new(Some(0), 4, 3, 1)),
            Num::Regular(3),
            Num::Pair(SnailTree::new(Some(2), 6, 5, 2)),
            Num::Regular(2),
            Num::Pair(SnailTree::new(Some(4), 8, 7, 3)),
            Num::Regular(1),
            Num::Pair(SnailTree::new(Some(6), 10, 9, 4)),
            Num::Regular(9),
            Num::Regular(8),
        ];

        let mut tree = Tree::new(t);

        println!("{:?}", tree.value);

        tree.explode(tree.walk_tree().unwrap());

        println!("{:?}", tree.value);
    }
}
