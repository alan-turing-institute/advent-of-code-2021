
// let input = "forward 5
// down 5
// forward 8
// up 3
// down 8
// forward 2"   .Split "\n"

let input = System.IO.File.ReadAllLines "day-02/fsharp_evelinag/day2_input.txt"

let instructionList = 
  input
  |> Array.map (fun s -> s.Split " " |> fun xs -> xs.[0], int xs.[1])
  |> List.ofArray  

let rec move1 (horizontal, depth) instructions =
  match instructions with
  | [] -> horizontal * depth
  | instruction :: rest ->
    match instruction with
    | ("forward", n) -> move1 (horizontal + n, depth) rest
    | ("down", n) -> move1 (horizontal, depth + n) rest
    | ("up", n) -> move1 (horizontal, depth - n) rest

let answer1 = move1 (0, 0) instructionList

let rec move2 (horizontal, depth, aim) instructions =
  match instructions with
  | [] -> horizontal * depth
  | instruction :: rest ->
    match instruction with
    | ("forward", n) -> move2 (horizontal + n, depth + n * aim, aim) rest
    | ("down", n) -> move2 (horizontal, depth, aim + n) rest
    | ("up", n) -> move2 (horizontal, depth, aim - n) rest

let answer2 = move2 (0,0,0) instructionList
