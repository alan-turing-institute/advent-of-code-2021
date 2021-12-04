
open System.IO

let lines = File.ReadAllLines("input.txt")       
let list = Seq.toList lines
let splitList = List.map  (fun (line: string) -> line.Split() |> fun l -> l[0], int l[1]) list 

// took me ages and I had to follow what Evelina did to understand how to use
// the recursive functions thing properly
let rec getDir (hor, dep) allList =
    match allList with
    | [] -> hor*dep
    | line :: tail -> 
    match line with
    | ("down",score) -> getDir (hor+score, dep) tail
    | ("up",score) -> getDir (hor-score, dep) tail
    | ("forward",score) -> getDir (hor, dep + score) tail

let score1 = getDir (0,0) splitList
printfn  "%i" score1

// let's see if if can write the second part without looking too much at Evelina's code
let rec getDir2 (hor,aim, dep) allList =
    match allList with
    | [] -> hor*dep
    | line :: tail -> 
    match line with
    | ("down",score) -> getDir2 (hor, aim+score, dep) tail
    | ("up",score) -> getDir2 (hor, aim-score, dep) tail
    | ("forward",score) -> getDir2 (hor+score, aim, dep + (score*aim)) tail

// ok, i think i got the logic
// but i don't think i'll be able to rewrite this again without help
let score2 = getDir2 (0,0,0) splitList
printfn  "%i" score2
