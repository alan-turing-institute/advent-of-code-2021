let input = "[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]".Split "\n"


let line = input.[0]

let input = System.IO.File.ReadAllLines "day-10/fsharp_evelinag/day10_input.txt"

type ParserResult =
  | Correct
  | Incomplete
  | Completion of string
  | Corrupted of int

let rec complete stack acc =
  match stack with
  | [] -> 
      acc 
      |> List.rev 
      |> String.concat "" 
      |> Completion
  | '('::xs -> complete xs (")"::acc)
  | '['::xs -> complete xs ("]"::acc)
  | '{'::xs -> complete xs ("}"::acc)
  | '<'::xs -> complete xs (">"::acc)



let rec parse stack (line: string) =
  if line.Length = 0 then
    match stack with
    | [] -> Correct // correct
    | _ -> 
      // Incomplete // part 1 answer
      complete stack [] // part 2 answer
  else
    match line.[0] with
    | '(' | '[' | '{' | '<' -> 
        parse (line.[0] :: stack) line.[1..]
    | ')' -> 
        match stack with
        | '('::xs -> parse xs line.[1..]
        | _ -> Corrupted 3
    | ']' ->
        match stack with
        | '['::xs -> parse xs line.[1..]
        | _ -> Corrupted 57
    | '}' ->
        match stack with
        | '{'::xs -> parse xs line.[1..]
        | _ -> Corrupted 1197
    | '>' ->
        match stack with
        | '<'::xs -> parse xs line.[1..]
        | _ -> Corrupted 25137

let answer1 =
  input
  |> Array.map (parse [])
  |> Array.sumBy (fun x -> 
      match x with
      | Corrupted c -> c
      | _ -> 0)


// part 2

let rec scoreCompletion acc (xs: string) =
  if xs.Length = 0 then 
    acc
  else
    let value =
      match xs.[0] with 
      | ')' -> 1L
      | ']' -> 2L
      | '}' -> 3L
      | '>' -> 4L
    scoreCompletion (value + 5L*acc) xs.[1..] 

let scores = 
  input
  |> Array.map (parse [])   
  |> Array.choose (fun x ->
      match x with Completion s -> Some s | _ -> None)     
  |> Array.map (scoreCompletion 0L)
  |> Array.sort

let answer2 = scores.[scores.Length/2]  