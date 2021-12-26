fn main() {
    println!("Hello, world!");
}

struct SnailTree {
    left: Box<Num>,
    right: Box<Num>,
    depth: u8,
}

impl SnailTree {
    fn new(left: Num, right: Num, depth: u8) -> Self {
        Self {
            left: Box::new(left),
            right: Box::new(right),
            depth,
        }
    }

    fn walk_tree(&self) {
        // Find nodes at depth 3 (nested in 4 brackets)
        // Explode the left node
        let mut stack = vec![self];

        while stack.len() > 0 {
            let node = stack.pop().unwrap();

            match &*node.left {
                Num::Regular(_) => {}
                Num::Pair(next_pair) => {
                    stack.push(next_pair);
                }
            };

            match &*node.right {
                Num::Regular(_) => {}
                Num::Pair(next_pair) => {
                    stack.push(next_pair);
                }
            };
        }
    }

    fn explode(&self) {}
}
enum Num {
    Regular(u8),
    Pair(SnailTree),
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

        let example_tree = SnailTree::new(
            Num::Pair(SnailTree::new(
                Num::Pair(SnailTree::new(
                    Num::Pair(SnailTree::new(
                        Num::Pair(SnailTree::new(Num::Regular(9), Num::Regular(8), 4)),
                        Num::Regular(1),
                        3,
                    )),
                    Num::Regular(2),
                    2,
                )),
                Num::Regular(3),
                1,
            )),
            Num::Regular(4),
            0,
        );

        example_tree.explode();
    }
}
