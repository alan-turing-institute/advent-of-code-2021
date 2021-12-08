let input = "be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce"
              .Split "\n"

let entries =
  //input
  System.IO.File.ReadAllLines("day-08/fsharp_evelinag/day8_input.txt")
  |> Array.map (fun line -> 
    line.Split "|"
    |> Array.map (fun parts -> 
        parts.Split " " 
        |> Array.filter ((<>) ""))
    |> fun xs -> 
        xs.[0] |> Array.map (Set)
        , xs.[1] |> Array.map (Set)
    )

let countUniqueDigits (entry : (char Set) []) =
  entry
  |> Seq.filter (fun x -> 
      match x.Count with
      | 2  | 4  | 3  | 7 -> true 
      | _ -> false)
  |> Seq.length

let nUnique =   
  entries
  |> Array.sumBy (fun (_, output) -> countUniqueDigits output)

//------------------------

//   0:      1:      2:      3:      4:
//  aaaa    ....    aaaa    aaaa    ....
// b    c  .    c  .    c  .    c  b    c
// b    c  .    c  .    c  .    c  b    c
//  ....    ....    dddd    dddd    dddd
// e    f  .    f  e    .  .    f  .    f
// e    f  .    f  e    .  .    f  .    f
//  gggg    ....    gggg    gggg    ....

//   5:      6:      7:      8:      9:
//  aaaa    aaaa    aaaa    aaaa    aaaa
// b    .  b    .  .    c  b    c  b    c
// b    .  b    .  .    c  b    c  b    c
//  dddd    dddd    ....    dddd    dddd
// .    f  e    f  .    f  e    f  .    f
// .    f  e    f  .    f  e    f  .    f
//  gggg    gggg    ....    gggg    gggg


let candidates number (digits: (char Set) []) =
  match number with
  | 0 | 6 | 9 -> digits |> Array.filter (fun xs -> xs.Count = 6)
  | 2 | 3 | 5 -> digits |> Array.filter (fun xs -> xs.Count = 5)
  | 1 -> digits |> Array.filter (fun xs -> xs.Count = 2)    
  | 4 -> digits |> Array.filter (fun xs -> xs.Count = 4) 
  | 7 -> digits |> Array.filter (fun xs -> xs.Count = 3)
  | 8 -> digits |> Array.filter (fun xs -> xs.Count = 7)       

// This is ugly and I don't like it
let decodeDigits (digits, output) =
  // get unique numbers first
  let one = digits |> candidates 1 |> Seq.exactlyOne
  let seven = digits |> candidates 7 |> Seq.exactlyOne
  let four = digits |> candidates 4 |> Seq.exactlyOne
  let eight = digits |> candidates 8 |> Seq.exactlyOne

  let digits' = digits |> Array.filter (fun x -> x <> one && x <> seven && x <> four && x <> eight )

  let a = Set.difference seven one
  let cf = one
  let bd = Set.difference four one 
  let eg = Set.difference (Set.difference eight seven) bd

  // number of common segments define a unique signature for each number
  let aOverlaps =  [1; 0; 1; 1; 0; 1; 1; 1; 1; 1]
  let cfOverlaps = [2; 2; 1; 2; 2; 1; 1; 2; 2; 2]
  let bdOverlaps = [1; 0; 1; 1; 2; 2; 2; 0; 2; 2]
  let egOverlaps = [2; 0; 2; 1; 0; 1; 2; 0; 2; 1]

  let signature = 
    let xs = [ aOverlaps; cfOverlaps; bdOverlaps; egOverlaps ]
    [0 .. 9]
    |> List.map (fun i -> [ aOverlaps.[i]; cfOverlaps.[i]; bdOverlaps.[i]; egOverlaps.[i]], i)
    |> Map
    
  // number of overlaps with the segments uniquely define a number
  let getNumber entry = 
    [ Set.intersect a entry |> Set.count
      Set.intersect cf entry |> Set.count
      Set.intersect bd entry |> Set.count 
      Set.intersect eg entry |> Set.count ]
    |> fun key -> signature.[key]
  
  let mapping =
    digits 
    |> Array.map (fun entry -> entry, getNumber entry)
    |> Map

  output 
  |> Array.map (fun x -> string mapping.[x]) 
  |> String.concat ""
  |> int

entries 
|> Array.sumBy decodeDigits