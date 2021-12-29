use std::{num::ParseIntError, str::FromStr};

fn main() {
    println!("Hello, world!");
}

#[derive(Debug)]
struct DepthNode<'a> {
    node: &'a Node,
    depth: usize,
}

impl<'a> DepthNode<'a> {
    fn new(node: &'a Node, depth: usize) -> Self {
        Self { node, depth }
    }
}

struct IterNode<'a> {
    stack: Vec<DepthNode<'a>>,
}

impl<'a> IterNode<'a> {
    fn new(root: &'a Node) -> Self {
        Self {
            stack: vec![DepthNode::new(root, 0)],
        }
    }
}

impl<'a> Iterator for IterNode<'a> {
    type Item = DepthNode<'a>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.stack.len() > 0 {

            let dn = self.stack.pop().expect("Still values on stack");

            
            if let Some(n) =  &dn.node.r {
                self.stack.push(DepthNode::new(n, dn.depth + 1));
            }

            if let Some(n) = &dn.node.l {
                self.stack.push(DepthNode::new(n, dn.depth + 1));
            }

            return Some(dn);
        }
        None
    }
}

// impl Tree {
//     fn parent(&self, node: &Node) {

//         let current_node = self.root;

//     }
// }

#[derive(Debug)]
struct Node {
    val: Num,
    l: Option<Box<Node>>,
    r: Option<Box<Node>>,
}

impl Node {
    fn new(val: Num) -> Self {
        Self {
            val: val,
            l: None,
            r: None,
        }
    }

    fn insert_left(&mut self, node: Option<Node>) -> &mut Node {
        match node {
            Some(n) => {self.l = Some(Box::new(n));},
            None => {self.l = None}
        };
        self.l.as_deref_mut().unwrap()
    }

    fn insert_right(&mut self, node: Option<Node>) -> &mut Node {
        match node {
            Some(n) => {self.r = Some(Box::new(n));},
            None => {self.r = None}
        };
        self.r.as_deref_mut().unwrap()
    }

    /// Find parent of node
    fn parent(&self, node: &Node) -> Option<&Node> {
        self.iter()
            .map(|x| x.node)
            .filter(|&x| {
                std::ptr::eq(node, x.l.as_ref().unwrap().as_ref())
                    | std::ptr::eq(node, x.r.as_ref().unwrap().as_ref())
            })
            .next()
    }

    /// Serialize to String
    fn to_string(&self) -> String {
        let mut output = String::new();

        if let Some(l) = &self.l {
            output.push_str("[");
            match l.val {
                Num::Pair => {
                    output.push_str(&l.to_string());
                }
                Num::Regular(val) => {
                    output.push_str(&format!("{}", val));
                }
            }

            output.push_str(",");
        }

        if let Some(r) = &self.r {
            match r.val {
                Num::Pair => {
                    output.push_str(&r.to_string());
                }
                Num::Regular(val) => {
                    output.push_str(&format!("{}", val));
                }
            }
            output.push_str("]");
        }

        output
    }

    fn iter(&self) -> IterNode {
        IterNode::new(self)
    }
}


impl FromStr for Node {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut stack: Vec<Node> = vec![];

        for i in 0..s.len() {
            let c = &s[i..i + 1];

            match c {
                "[" => {
                    stack.push(Node::new(Num::Pair));
                }
                "," => {}
                "]" => {
                    let right_node = stack.pop().unwrap();
                    let left_node = stack.pop().unwrap();
                    let parent = stack.last_mut().unwrap();

                    parent.insert_left(Some(left_node));
                    parent.insert_right(Some(right_node));
                }
                _ => {
                    let mut longer_c = &s[i..i + 2];
                    if longer_c.contains(",") | longer_c.contains("]") {
                        longer_c = c;
                    }
                    stack.push(Node::new(Num::Regular(longer_c.parse::<u8>().unwrap())));
                }
            }
        }

        Ok(stack.pop().unwrap())
    }
}

// #[derive(Debug, Clone, Copy, PartialEq)]
// struct SnailTree {
//     parent: Option<usize>,
//     left: Option<usize>,
//     right: Option<usize>,
//     depth: u8,
// }

// impl SnailTree {
//     fn new(parent: Option<usize>, left: Option<usize>, right: Option<usize>, depth: u8) -> Self {
//         Self {
//             parent,
//             left,
//             right,
//             depth,
//         }
//     }
// }

// #[derive(Debug, Clone, Copy, PartialEq)]
// struct Regular {
//     value: u8,
// }

// impl Regular {
//     fn new(parent: Option<usize>, value: u8) -> Self {
//         Self { parent, value }
//     }
// }

#[derive(Debug, Clone, Copy, PartialEq)]
enum Num {
    Regular(u8),
    Pair,
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

        // let mut root = Node::new(Num::Pair);
        // let mut node_l = root.insert_left(Num::Pair);
        // // let mut node_r = root.insert_right(Num::Regular(4));

        // node_l.insert_right(Num::Regular(3));
        // node_l.insert_right(Num::Regular(3));

        // if let Some(l) = node_l {
        //     l.insert_left(Num::Regular(3));

        // }
        // node_l.insert_right(Num::Regular(3));

        // let t = vec![
        //     Num::Pair(SnailTree::new(None, Some(2), Some(1), 0)),
        //     Num::Regular(4),
        //     Num::Pair(SnailTree::new(Some(0), Some(4), Some(3), 1)),
        //     Num::Regular(3),
        //     Num::Pair(SnailTree::new(Some(2), Some(6), Some(5), 2)),
        //     Num::Regular(2),
        //     Num::Pair(SnailTree::new(Some(4), Some(8), Some(7), 3)),
        //     Num::Regular(1),
        //     Num::Pair(SnailTree::new(Some(6), Some(9), Some(10), 4)),
        //     Num::Regular(9),
        //     Num::Regular(8),
        // ];
    }

    //     let mut tree = Tree::new(t);

    //     println!("{:?}", tree.value);

    //     // tree.walk_tree();
    //     // tree.explode(tree.walk_tree().unwrap());

    //     // println!("{:?}", tree.value);
    // }

    #[test]
    fn test_parse() {
        let s = "[[[[[9,8],1],2],3],4]";
        let root = Node::from_str(s).unwrap();
        assert_eq!(s, root.to_string());

        let s = "[[1,2],3]";
        let root = Node::from_str(s).unwrap();
        assert_eq!(s, root.to_string());

        let s = "[9,[8,7]]";
        let root = Node::from_str(s).unwrap();
        assert_eq!(s, root.to_string());

        let s = "[[1,9],[8,5]]";
        let root = Node::from_str(s).unwrap();
        assert_eq!(s, root.to_string());

        let s = "[[[[1,2],[3,4]],[[5,6],[7,8]]],9]";
        let root = Node::from_str(s).unwrap();
        assert_eq!(s, root.to_string());

        let s = "[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]";
        let root = Node::from_str(s).unwrap();
        assert_eq!(s, root.to_string());

        let s = "[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]";
        let root = Node::from_str(s).unwrap();
        assert_eq!(s, root.to_string());

        //     let explode_pair = tree.iter().filter(|&x| matches!(x, Num::Pair(_))).filter(|&x| x.unwrap_snailtree().depth == 4).nth(0).unwrap();

        //     println!("explode = {:?}", explode_pair);

        //     let explode_idx = if tree.is_left_of_parent(explode_pair) {
        //         tree.value[explode_pair.parent_idx().unwrap()].unwrap_snailtree().left.unwrap()
        //     } else {
        //         tree.value[explode_pair.parent_idx().unwrap()].unwrap_snailtree().right.unwrap()
        //     };

        //     tree.explode(explode_idx);

        //     println!("\n\n{:#?}", tree.value);

        //     // tree.walk_tree();

        //     // let walked = tree
        //     //     .iter()
        //     //     .filter(|&x| matches!(x, Num::Regular(_)))
        //     //     .collect::<Vec<_>>();\

        //     // println!("{:?}", tree.iter().collect::<Vec<_>>());

        //     let out = tree.iter().fold(String::new(), |mut acc, x| {

        //         // println!("{:?}", x);

        //         if tree.is_right_of_parent(x) {
        //             acc.push(',');
        //         }

        //         match x {
        //             Num::Regular(reg) => {
        //                 acc.push_str(&format!("{}", reg.value));

        //             },
        //             Num::Pair(_) => {acc.push('[');}
        //         };

        //         // if tree.is_left_of_parent(x) {
        //         //     acc.push(',');
        //         // }
        //         if tree.is_right_of_parent(x) {
        //             acc.push(']');
        //         }

        //         acc
        //     });
        //     println!("\n{:?}", out);

        //     // assert_eq!(out, s);
    }

    #[test]
    fn test_iter() {
        let s = "[[[[[9,8],1],2],3],4]";
        let root = Node::from_str(s).unwrap();

        let nodes = root
            .iter()
            .filter(|x| matches!(x.node.val, Num::Regular(_)))
            .collect::<Vec<_>>();

        println!("{:?}", nodes);

        // assert_eq!(s, root.to_string());
    }

    #[test]
    fn test_explode() {
        let s = "[[[[[9,8],1],2],3],4]";
        let root = Node::from_str(s).unwrap();

        let node = root
            .iter()
            .filter(|x| x.depth == 4)
            .map(|x| x.node)
            .nth(0)
            .unwrap();


        // let parent = &mut *root.parent(node).unwrap();
        // node.insert_left(None);
        // println!("{:#?}", node);

        // How to find a nodes parent
        // let parent = root
        //     .iter()
        //     .map(|x| x.node)
        //     .filter(|&x| {
        //         std::ptr::eq(node, x.l.as_ref().unwrap().as_ref())
        //             | std::ptr::eq(node, x.r.as_ref().unwrap().as_ref())
        //     })
        //     .next()
        //     .unwrap();

        println!("{:#?}", root.parent(node));
        // assert_eq!(s, root.to_string());
    }
}
