open System.IO

let grid = 
  //File.ReadAllLines "day-11/fsharp_evelinag/day11_sample.txt"
  File.ReadAllLines "day-11/fsharp_evelinag/day11_input.txt"
  |> Array.map (fun line -> 
      line 
      |> Seq.map (string >> int)
      |> Seq.toArray)      

let neighbours (row,col) =
  [
    if row > 0 then yield! [ row - 1 ]
    row
    if row < 9 then yield! [ row + 1]
  ]     
  |> List.collect (fun r ->
    [
      if col > 0 then yield! [ r, col - 1 ]
      r, col
      if col < 9 then yield! [ r, col + 1 ]
    ]) 
  |> List.filter ((<>) (row, col))

let rec updateFlashes (grid : int [][]) = 
  
  let newGrid = grid |> Array.copy   

  let rec flash acc (toUpdate: (int*int) list) =
    match toUpdate with
    | [] -> acc
    | (i,j)::fs ->
      match newGrid.[i].[j] with
      | 0 -> // already flashed in the current cycle
          flash acc fs
      | x when x < 9 && x > 0 ->
          // increase
          newGrid.[i].[j] <- newGrid.[i].[j] + 1
          flash acc fs
      | x when x = 9 ->
          // will flash in the next cycle
          newGrid.[i].[j] <- newGrid.[i].[j] + 1
          flash acc ((i,j)::fs)
      | x when x > 9 ->
          newGrid.[i].[j] <- 0
          flash (acc+1) (List.append (neighbours (i,j)) fs)

  let toFlash =
    newGrid 
    |> Array.mapi (fun i row ->
      row |> Array.mapi (fun j x -> if x > 9 then Some (i,j) else None))
    |> Array.concat
    |> Array.choose id
    |> List.ofArray

  if toFlash.Length = 0 then 
    0, newGrid
  else
    let nFlashes = flash 0 toFlash
    nFlashes, newGrid

let print grid = 
  grid
  |> Array.iter (fun row -> 
      row 
      |> Array.iter (fun x -> printf "%d" x)
      printf "\n")
  printf "\n\n"

let rec simulate n count (grid: int [][]) =
  if n = 0 then 
    count, grid
  else
    let grid' =
      [| for row in 0..grid.Length-1 ->
          [| for col in 0..grid.[0].Length-1 ->
              grid.[row].[col] + 1
          |] 
      |]

    let count', grid'' = updateFlashes grid'  
    simulate (n-1) (count + count') grid''

let n = simulate 100 0 grid

// part 2

let rec allFlash n (grid: int [][]) =
  // check if finished
  let isFinished =
    grid 
    |> Array.sumBy (fun row -> 
        row |> Array.sumBy id)
    |> (=) 0

  if isFinished then 
    n
  else
    let grid' =
      [| for row in 0..grid.Length-1 ->
          [| for col in 0..grid.[0].Length-1 ->
              grid.[row].[col] + 1
          |] 
      |]

    let _, grid'' = updateFlashes grid'  

    allFlash (n+1) grid'' 

allFlash 0 grid

