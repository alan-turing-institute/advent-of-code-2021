let input = "7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7"

type BingoNumber = 
  | Marked of int
  | Unmarked of int

type Board = BingoNumber[][]

let parse (input: string) = 
  let parts = input.Split "\n\n"
  let numbers = parts.[0].Split "," |> Array.map int |> List.ofArray
  let boards : Board [] = 
    parts.[1..]
    |> Array.map (fun board ->
        board.Split "\n"
        |> Array.map (fun line -> 
          line.Split " " 
          |> Array.filter ((<>)"")
          |> Array.map (fun x -> Unmarked (int x))))
  numbers, boards

let markNumber n (board : Board) : Board =
  board
  |> Array.map (fun row ->
      row
      |> Array.map (fun x ->
          match x with
          | Unmarked y when y = n -> Marked n
          | _ -> x))

let isWinning (board: Board) = 
  // check rows
  let checkRows = 
    board
    |> Array.map (fun row -> 
        row 
        |> Array.sumBy (fun x -> 
            match x with
            | Marked _ -> 1
            | Unmarked _ -> 0))          
    |> Array.contains 5
  let checkColumns =
    [|0..4|]
    |> Array.map (fun i ->
        board 
        |> Array.sumBy (fun row -> 
            match row.[i] with 
            | Marked _ -> 1
            | Unmarked _ -> 0)) 
    |> Array.contains 5
  checkRows || checkColumns 

let calculateScore n (board: Board) = 
  board
  |> Array.sumBy (fun row -> 
      row 
      |> Array.sumBy (fun x -> match x with Unmarked y -> y | _ -> 0))
  |> (*) n

// Calculate the actual solution

let numbers, boards = 
  //parse input
  parse (System.IO.File.ReadAllText "day-04/fsharp_evelinag/day4_input.txt")

let rec findFirstWinning numbers boards = 
  match numbers with
  | [] -> 0
  | n :: ns ->
    // mark number that's been drawn
    let boards' = 
      boards
      |> Array.map (markNumber n)

    // check for winning board
    let winningBoard = 
      boards'
      |> Array.filter isWinning
      |> fun b -> if b.Length = 0 then None else Some(b.[0])

    match winningBoard with 
    | Some board -> calculateScore n board
    | None -> findFirstWinning ns boards'

findFirstWinning numbers boards

// part 2

let rec findLastWinning numbers lastWinning boards = 
  printfn "%A\n\n" lastWinning 
  match numbers with
  | [] -> 
      match lastWinning with
      | Some n, Some board -> calculateScore n board
      | _ -> 0 // something went probably wrong

  | n :: ns ->
    // mark number that's been drawn
    let boards' = 
      boards
      |> Array.map (markNumber n)

    // check for winning board
    let winningBoard = 
      boards'
      |> Array.filter isWinning
      |> fun b -> if b.Length = 0 then None else Some(b.[0])

    let remainingBoards = 
      boards'
      |> Array.filter (isWinning >> not)

    match winningBoard with 
    | Some board -> 
        findLastWinning ns (Some n, winningBoard) remainingBoards
    | None -> 
        findLastWinning ns lastWinning remainingBoards

findLastWinning numbers (None, None) boards