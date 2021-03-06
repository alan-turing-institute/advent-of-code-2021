use core::num;
use std::{cell::RefCell, fs, num::ParseIntError, ops::Add, rc::Rc, str::FromStr};

fn main() {
    let input = fs::read_to_string("input.txt").unwrap();

    let mut numbers = input.lines().map(|number| Tree::from_str(number).unwrap());
    let first_number = numbers.next().unwrap();
    let part1 = numbers.fold(first_number, |acc, x| acc + x).magnitude();

    println!("Part 1 = {}", part1);

    let numbers = input.lines();
    let numbers2: Vec<_> = input.lines().collect();

    let part2 = numbers
        .enumerate()
        .map(|(i, t1)| {
            numbers2
                .iter()
                .enumerate()
                .filter(|inner| inner.0 != i)
                .map(|(_, &t2)| {
                    (Tree::from_str(t1).unwrap() + Tree::from_str(t2).unwrap()).magnitude()
                })
                .max()
                .unwrap()
        })
        .max()
        .unwrap();

    println!("Part 2 = {}", part2);
}

#[derive(Debug)]
struct NotRegularNumber;

#[derive(Debug)]
struct DepthNode {
    node: TreeNode,
    depth: usize,
}

impl DepthNode {
    fn new(node: TreeNode, depth: usize) -> Self {
        Self { node, depth }
    }
}

struct IterNode {
    stack: Vec<DepthNode>,
}

impl IterNode {
    fn new(root: TreeNode) -> Self {
        Self {
            stack: vec![DepthNode::new(root, 0)],
        }
    }
}

impl Iterator for IterNode {
    type Item = DepthNode;

    fn next(&mut self) -> Option<Self::Item> {
        if self.stack.len() > 0 {
            let dn = self.stack.pop().expect("Still values on stack");

            if let Some(n) = &dn.node.borrow().r {
                self.stack.push(DepthNode::new(Rc::clone(n), dn.depth + 1));
            }

            if let Some(n) = &dn.node.borrow().l {
                self.stack.push(DepthNode::new(Rc::clone(n), dn.depth + 1));
            }

            return Some(dn);
        }
        None
    }
}

struct IterNodeLeft {
    stack: Vec<DepthNode>,
}

impl IterNodeLeft {
    fn new(root: TreeNode) -> Self {
        Self {
            stack: vec![DepthNode::new(root, 0)],
        }
    }
}

impl Iterator for IterNodeLeft {
    type Item = DepthNode;

    fn next(&mut self) -> Option<Self::Item> {
        if self.stack.len() > 0 {
            let dn = self.stack.pop().expect("Still values on stack");

            if let Some(n) = &dn.node.borrow().l {
                self.stack.push(DepthNode::new(Rc::clone(n), dn.depth + 1));
            }

            if let Some(n) = &dn.node.borrow().r {
                self.stack.push(DepthNode::new(Rc::clone(n), dn.depth + 1));
            }
            return Some(dn);
        }
        None
    }
}

type TreeNode = Rc<RefCell<Node>>;

#[derive(Debug)]
struct Tree {
    root: TreeNode,
}

impl Add for Tree {
    type Output = Tree;

    fn add(self, other: Tree) -> Tree {
        let mut root = Node::new(Num::Pair);

        root.insert_left(Some(Rc::try_unwrap(self.root).unwrap().into_inner()));
        root.insert_right(Some(Rc::try_unwrap(other.root).unwrap().into_inner()));

        let mut tree = Tree {
            root: Rc::new(RefCell::new(root)),
        };

        loop {
            let explode = tree.explode();

            if explode.is_none() {
                let split = tree.split();
                if split.is_none() {
                    break;
                }
            }
        }

        tree
    }
}

impl Tree {
    fn magnitude(&self) -> u64 {
        self.root.borrow().magnitude()
    }

    /// Start iterating from a given node
    fn iter_from(&self, node: &TreeNode) -> IterNode {
        IterNode::new(Rc::clone(node))
    }

    /// Depth first iteration of tree
    fn iter(&self) -> IterNode {
        IterNode::new(Rc::clone(&self.root))
    }

    /// Start iterating from a given node
    fn iter_left_from(&self, node: &TreeNode) -> IterNodeLeft {
        IterNodeLeft::new(Rc::clone(node))
    }

    /// Depth first iteration of tree
    fn iter_left(&self) -> IterNodeLeft {
        IterNodeLeft::new(Rc::clone(&self.root))
    }

    /// Find parent of a node
    fn parent(&self, node: &TreeNode) -> Option<TreeNode> {
        self.iter()
            .map(|x| x.node)
            .filter(|x| {
                let x_ref = &x.borrow();
                let right = x_ref.r.as_ref();
                let left = x_ref.l.as_ref();

                (right.is_some() && Rc::ptr_eq(node, right.unwrap()))
                    || (left.is_some() && Rc::ptr_eq(node, &x.borrow().l.as_ref().unwrap()))
            })
            .next()
    }

    /// Serialise tree to string
    fn to_string(&self) -> String {
        self.root.borrow().to_string()
    }

    /// Find the first regular number to the left of a node
    fn first_left_regular(&self, node: &TreeNode) -> Option<TreeNode> {
        let parent = self.parent(node)?;

        let ret = match parent.borrow().left() {
            Some(_) => {
                if Rc::ptr_eq(node, parent.borrow().l.as_ref().unwrap()) {
                    self.first_left_regular(&parent)
                } else {
                    let val = self
                        .iter_left_from(parent.borrow().l.as_ref().unwrap())
                        .filter(|x| matches!(x.node.borrow().val, Num::Regular(_)))
                        .next();
                    match val {
                        Some(v) => Some(v.node),
                        None => self.first_left_regular(&parent),
                    }
                }
            }
            None => self.first_left_regular(&parent),
        };

        ret
    }

    /// Find the first regular number to the right of a node
    fn first_right_regular(&self, node: &TreeNode) -> Option<TreeNode> {
        let parent = self.parent(node)?;

        let ret = match parent.borrow().right() {
            Some(_) => {
                if Rc::ptr_eq(node, parent.borrow().r.as_ref().unwrap()) {
                    self.first_right_regular(&parent)
                } else {
                    let val = self
                        .iter_from(parent.borrow().r.as_ref().unwrap())
                        .filter(|x| matches!(x.node.borrow().val, Num::Regular(_)))
                        .next();
                    match val {
                        Some(v) => Some(v.node),
                        None => self.first_right_regular(&parent),
                    }
                }
            }
            None => self.first_right_regular(&parent),
        };

        ret
    }

    fn explode(&mut self) -> Option<()> {
        let nested_node = self
            .iter()
            .filter(|x| x.depth == 5)
            .map(|x| x.node)
            .next()?;

        let parent = self.parent(&nested_node)?;

        let left_regular = parent
            .borrow_mut()
            .take_left()
            .regular()
            .expect("Has a left Num::Regular");

        let right_regular = parent
            .borrow_mut()
            .take_right()
            .regular()
            .expect("Has a right Num::Regular");

        // Find the first Num::Regular to the left and right
        let first_left = self.first_left_regular(&parent);
        let first_right = self.first_right_regular(&parent);

        if let Some(node) = first_left {
            let mut left_node = node.borrow_mut();
            left_node.val =
                Num::Regular(left_node.val.regular().expect("Is Num::Regular") + left_regular);
        }

        if let Some(node) = first_right {
            let mut right_node = node.borrow_mut();
            right_node.val =
                Num::Regular(right_node.val.regular().expect("Is Num::Regular") + right_regular);
        }

        // Replace parent with 0
        let mut parent_val = parent.borrow_mut();
        parent_val.val = Num::Regular(0);

        Some(())
    }

    fn split(&mut self) -> Option<()> {
        let large_node = self
            .iter()
            .filter(|x| matches!(x.node.borrow().val, Num::Regular(_)))
            .filter(|x| x.node.borrow().val.regular().expect("A regular number") >= 10)
            .map(|x| x.node)
            .next()?;

        let mut large_node = large_node.borrow_mut();
        let current_val = large_node.val.regular().unwrap() as f64;
        let current_floored = (current_val / 2.0).floor() as u8;
        let current_ceil = (current_val / 2.0).ceil() as u8;

        large_node.insert_left(Some(Node::new(Num::Regular(current_floored))));
        large_node.insert_right(Some(Node::new(Num::Regular(current_ceil))));

        large_node.val = Num::Pair;

        Some(())
    }
}

#[derive(Debug, PartialEq)]
struct Node {
    val: Num,
    l: Option<TreeNode>,
    r: Option<TreeNode>,
}

impl Node {
    fn new(val: Num) -> Self {
        Self {
            val: val,
            l: None,
            r: None,
        }
    }

    fn insert_left(&mut self, node: Option<Node>) -> Option<Rc<RefCell<Node>>> {
        match node {
            Some(n) => {
                self.l = Some(Rc::new(RefCell::new(n)));
            }
            None => self.l = None,
        };
        Some(Rc::clone(&self.l.as_ref().unwrap()))
    }

    fn insert_right(&mut self, node: Option<Node>) -> Option<Rc<RefCell<Node>>> {
        match node {
            Some(n) => {
                self.r = Some(Rc::new(RefCell::new(n)));
            }
            None => self.r = None,
        };
        Some(Rc::clone(&self.r.as_ref().unwrap()))
    }

    fn take_left(&mut self) -> Num {
        self.l.take().unwrap().borrow().val
    }

    fn take_right(&mut self) -> Num {
        self.r.take().unwrap().borrow().val
    }

    fn left(&self) -> Option<Num> {
        Some(self.l.as_ref()?.borrow().val)
    }

    fn right(&self) -> Option<Num> {
        Some(self.r.as_ref()?.borrow().val)
    }

    fn magnitude(&self) -> u64 {
        // parent.borrow().r.as_ref().unwrap()
        match self.val {
            Num::Regular(v) => v as u64,
            Num::Pair => {
                Rc::clone(self.l.as_ref().unwrap()).borrow().magnitude() * 3
                    + Rc::clone(self.r.as_ref().unwrap()).borrow().magnitude() * 2
            }
        }
    }
    /// Serialize to String
    fn to_string(&self) -> String {
        let mut output = String::new();

        if let Some(l) = &self.l {
            output.push_str("[");

            match l.borrow().val {
                Num::Pair => {
                    output.push_str(&l.borrow().to_string());
                }
                Num::Regular(val) => {
                    output.push_str(&format!("{}", val));
                }
            }

            output.push_str(",");
        }

        if let Some(r) = &self.r {
            match r.borrow().val {
                Num::Pair => {
                    output.push_str(&r.borrow().to_string());
                }
                Num::Regular(val) => {
                    output.push_str(&format!("{}", val));
                }
            }
            output.push_str("]");
        }

        output
    }
}

impl FromStr for Tree {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut stack: Vec<Node> = vec![];

        let mut i = 0;
        while i < s.len() {
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
                    } else {
                        i += 1;
                    }
                    stack.push(Node::new(Num::Regular(longer_c.parse::<u8>().unwrap())));
                }
            }

            i += 1;
        }

        Ok(Self {
            root: Rc::new(RefCell::new(stack.pop().unwrap())),
        })
    }
}

#[derive(Debug, Clone, Copy, PartialEq)]
enum Num {
    Regular(u8),
    Pair,
}

impl Num {
    fn regular(&self) -> Result<u8, NotRegularNumber> {
        if let Num::Regular(val) = self {
            Ok(*val)
        } else {
            Err(NotRegularNumber)
        }
    }
}

#[cfg(test)]
mod tests {

    use super::*;
    use test_case::test_case;

    #[test_case("[[[[[9,8],1],2],3],4]"  ; "case 1")]
    #[test_case("[[1,2],3]"  ; "case 2")]
    #[test_case("[9,[8,7]]"  ; "case 3")]
    #[test_case("[[1,9],[8,5]]"  ; "case 4")]
    #[test_case("[[[[1,2],[3,4]],[[5,6],[7,8]]],9]"  ; "case 5")]
    #[test_case("[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]"  ; "case 6")]
    #[test_case("[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]" ; "case 7")]
    #[test_case("[[1,2],10]" ; "case 8")]
    fn test_parse(s: &str) {
        let tree = Tree::from_str(s).unwrap();

        let v: Vec<_> = tree
            .iter()
            .filter(|x| matches!(x.node.borrow().val, Num::Regular(_)))
            .collect();
        println!("{:#?}", v);
        assert_eq!(s, tree.root.borrow().to_string());
    }

    #[test_case("[[[[[9,8],1],2],3],4]", "[[[[0,9],2],3],4]"  ; "case 1")]
    #[test_case("[7,[6,[5,[4,[3,2]]]]]", "[7,[6,[5,[7,0]]]]"  ; "case 2")]
    #[test_case("[[6,[5,[4,[3,2]]]],1]" , "[[6,[5,[7,0]]],3]"; "case 3")]
    #[test_case("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]" ; "case 4")]
    #[test_case("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]", "[[3,[2,[8,0]]],[9,[5,[7,0]]]]"  ; "case 5")]
    #[test_case("[[[[[3,2],4],5],6],[3,[2,[1,[7,3]]]]]", "[[[[0,6],5],6],[3,[2,[1,[7,3]]]]]"  ; "case 6")]
    #[test_case("[[[[2,4],5],6],[[[[7,3],1],2],3]]", "[[[[2,4],5],13],[[[0,4],2],3]]"  ; "case 7")]
    fn test_explode(s: &str, r: &str) {
        let mut tree = Tree::from_str(s).unwrap();
        assert_eq!(tree.to_string(), s);
        tree.explode();
        println!("{}", tree.to_string());
        assert_eq!(r, tree.to_string());
    }

    #[test_case("[[[[[10,8],1],2],3],4]", "[[[[[[5,5],8],1],2],3],4]"  ; "case 1")]

    fn test_split(s: &str, r: &str) {
        let mut tree = Tree::from_str(s).unwrap();
        tree.split();
        assert_eq!(r, tree.to_string());
    }

    #[test_case("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"; "right exploded")]
    fn test_iterator(s: &str) {
        let tree = Tree::from_str(s).unwrap();

        let depths: Vec<_> = tree
            .iter()
            .filter(|x| matches!(x.node.borrow().val, Num::Regular(_)))
            .collect();

        println!("{:#?}", depths);
    }

    #[test_case("[[1,2],[[3,4],5]]", 143; "example 1")]
    #[test_case("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]", 1384; "example 2")]
    #[test_case("[[[[1,1],[2,2]],[3,3]],[4,4]]", 445; "example 3")]
    #[test_case("[[[[3,0],[5,3]],[4,4]],[5,5]]", 791; "example 4")]
    #[test_case("[[[[5,0],[7,4]],[5,5]],[6,6]]", 1137; "example 5")]
    #[test_case("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]", 3488; "example 6")]
    fn test_magnitude(s: &str, magnitude: u64) {
        let tree = Tree::from_str(s).unwrap();

        assert_eq!(tree.magnitude(), magnitude);
    }

    #[test_case("[[[[4,3],4],4],[7,[[8,4],9]]]", "[1,1]", "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"; "example 1")]
    #[test_case("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]", "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]", "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]"; "example 2")]
    fn test_addition(s1: &str, s2: &str, exp: &str) {
        let tree_left = Tree::from_str(s1).unwrap();
        let tree_right = Tree::from_str(s2).unwrap();

        let tree = tree_left + tree_right;

        println!("{}", tree.to_string());

        assert_eq!(exp, tree.to_string())
    }

    // #[test_case("[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]", "[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]", "[[[[4,0],[5,4]],[[7,7],[6,0]]],[[8,[7,7]],[[7,9],[5,0]]]]"; "example 2")]
    // fn test_addition_debug(s1: &str, s2: &str, exp: &str) {

    //     let tree_left = Tree::from_str(s1).unwrap();
    //     let tree_right  = Tree::from_str(s2).unwrap();

    //     let mut root = Node::new(Num::Pair);

    //     root.insert_left(Some(Rc::try_unwrap(tree_left.root).unwrap().into_inner()));
    //     root.insert_right(Some(Rc::try_unwrap(tree_right.root).unwrap().into_inner()));

    //     let mut tree = Tree {
    //         root: Rc::new(RefCell::new(root)),
    //     };

    //     println!("{}", tree.to_string());

    //     tree.explode();

    //     println!("{}", tree.to_string());

    //     tree.explode();

    //     println!("{}", tree.to_string());

    // }

    #[test]
    fn test_part1() {
        const EXAMPLE: &str = "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]";

        let mut numbers = EXAMPLE
            .lines()
            .map(|number| Tree::from_str(number).unwrap());
        let start = numbers.next().unwrap();
        let summed = numbers.fold(start, |acc, x| {
            let a = acc + x;
            println!("{}", a.to_string());
            a
        });
        assert_eq!(
            "[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]",
            summed.to_string()
        );
        assert_eq!(summed.magnitude(), 4140);
    }
}
