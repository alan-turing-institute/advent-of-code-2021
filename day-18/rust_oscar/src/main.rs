use std::{cell::RefCell, num::ParseIntError, rc::Rc, str::FromStr};

fn main() {
    println!("Hello, world!");
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

// pub struct IterMut<'a> {
//     next: Option<&'a mut Node>,
// }

// #[derive(Debug)]
// struct DepthNodeMut<'a> {
//     node: &'a mut Node,
// }

// impl<'a> DepthNodeMut<'a> {
//     fn new(node: &'a mut Node) -> Self {
//         Self { node }
//     }
// }

// struct IterMutNode<'a> {
//     next: Option<&'a mut Node>,
//     left_side: bool
// }

// impl<'a> IterMutNode<'a> {
//     fn new(root: &'a mut Node) -> Self {
//         Self {
//             stack: vec![DepthNodeMut::new(root)],
//         }
//     }
// }

// impl<'a> Iterator for IterMutNode<'a> {
//     type Item = &'a mut Node;

//     fn next(&mut self) -> Option<Self::Item> {

//         let a = self.next;

// if self.left_side {
//     self.left_side = false;

// }

// self.next

//     if self.stack.len() > 0 {

//         let node = self.stack.pop().expect("Still values on stack");

//         self.stack.push(node.l.as_deref_mut().unwrap());

//         // if let Some(mut n) =  r.take()
//         //  {

//         //     self.stack.push(&mut n);
//         // }

//         // if let Some(n) = &dn.node.l {
//         //     self.stack.push(DepthNodeMut::new(&mut *n.as_ref()));
//         // }

//         return Some(node);
//     }
// None

//     }
// }

// impl Tree {
//     fn parent(&self, node: &Node) {

//         let current_node = self.root;

//     }
// }

type TreeNode = Rc<RefCell<Node>>;

#[derive(Debug)]
struct Tree {
    root: TreeNode,
}

impl Tree {

    // Add two nodes together
    fn addition(left: Node, right: Node) -> Self {

        let mut root = Node::new(Num::Pair);

        root.insert_left(Some(left));
        root.insert_right(Some(right));

        Self {
            root: Rc::new(RefCell::new(root))
        }

    }
    /// Start iterating from a given node
    fn iter_from(&self, node: &TreeNode) -> IterNode {
        IterNode::new(Rc::clone(node))
    }
    fn iter(&self) -> IterNode {
        IterNode::new(Rc::clone(&self.root))
    }

    /// Find parent of node
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

    fn to_string(&self) -> String {
        self.root.borrow().to_string()
    }

    fn first_left_regular(&self, node: &TreeNode) -> Option<TreeNode> {
        let parent = self.parent(node)?;

        let ret = match parent.borrow().left() {
            Some(r) => {
                if Rc::ptr_eq(node, parent.borrow().l.as_ref().unwrap()) {
                    self.first_left_regular(&parent)
                } else {
                    let val = self
                        .iter_from(parent.borrow().l.as_ref().unwrap())
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

    fn first_right_regular(&self, node: &TreeNode) -> Option<TreeNode> {
        let parent = self.parent(node)?;

        let ret = match parent.borrow().right() {
            Some(r) => {
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

        // let ret = match parent.borrow().right()? {
        //     Num::Pair => {
        //         let next = self
        //             .iter_from(parent.borrow().r.as_ref().unwrap())
        //             .filter(|x| matches!(x.node.borrow().val, Num::Regular(_)))
        //             .next();
        //         match next {
        //             Some(dn) => Some(dn.node),
        //             None => self.first_right_regular(&parent),
        //         }
        //     }
        //     Num::Regular(_) => Some(Rc::clone(parent.borrow().r.as_ref().unwrap())),
        // };

        // ret

        // else {

        //     let right = node.borrow().right()?;
        //     ret = match right {

        //         // See if left is Regular, else step right
        //         Num::Pair => {
        //             //
        //             // let right_ref = node.borrow();
        //             // let right_node = node.borrow().r.as_ref().unwrap();

        //             match node.borrow().r.as_ref().unwrap().borrow().left() {
        //                 Some(Num::Regular(_)) => { Some(Rc::clone(node.borrow().r.as_ref().unwrap().borrow().l.as_ref().unwrap()) )},

        //                 _ => { self.first_right_regular(node.borrow().r.as_ref().unwrap(), false) }

        //             }

        //         },
        //         Num::Regular(_) => Some(Rc::clone(node.borrow().r.as_ref().unwrap())),
        //     }
        // }
    }

    fn explode(&mut self) -> Option<()> {
        let nested_node = self
            .iter()
            .filter(|x| x.depth == 5)
            .map(|x| x.node)
            .next()?;

        // println!("{:#?}", nested_node);

        let parent = self.parent(&nested_node)?;

        // println!("P = {:#?}", parent);

        // println!("R = {:#?}", parent_mut.left());
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

    // fn iter_mut(&self) -> IterMutNode {
    //     IterMutNode{stack: vec![&mut Box::new(self) ]}
    // }
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

impl Num {
    fn regular(&self) -> Result<u8, NotRegularNumber> {
        if let Num::Regular(val) = self {
            Ok(*val)
        } else {
            Err(NotRegularNumber)
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
    fn test_explode(s: &str, r: &str) {
        let mut tree = Tree::from_str(s).unwrap();
        tree.explode();
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

    #[test_case("[[[[4,3],4],4],[7,[[8,4],9]]]", "[1,1]"; "example 1")]
    fn test_reduce(s1: &str, s2: &str) {

        let left_node = Rc::try_unwrap(Tree::from_str(s1).unwrap().root).unwrap().into_inner();
        let right_node = Rc::try_unwrap(Tree::from_str(s2).unwrap().root).unwrap().into_inner();


        let mut tree = Tree::addition(left_node, right_node);
    
        
        loop {
            let explode = tree.explode();

            if explode.is_none() {
                let split = tree.split();
                if split.is_none() {
                    break
                }
            }
         
        }


        println!("{}", tree.to_string());

        assert_eq!("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]", tree.to_string())

        // let depths: Vec<_> = tree
        //     .iter()
        //     .filter(|x| matches!(x.node.borrow().val, Num::Regular(_)))
        //     .collect();

        // println!("{:#?}", depths);
    }
}
