let input = "0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2"  .Split "\n"

let linesEndpoints = 
  //input
  System.IO.File.ReadAllLines("day-05/fsharp_evelinag/day5_input.txt")
  |> Array.map (fun lineText ->
      lineText.Split " -> " 
      |> Array.map (fun point -> 
          point.Split ","
          |> Array.map int
          |> fun xs -> xs.[0], xs.[1])
      |> fun xs -> xs.[0], xs.[1])

let linesFull = 
  // expand each horizontal or vertical line
  linesEndpoints
  |> Array.choose (fun ((x1, y1), (x2, y2)) ->
      if x1 = x2 then 
        [| min y1 y2 .. max y1 y2 |] 
        |> Array.map (fun y -> (x1, y))
        |> Some
      else if y1 = y2 then
        [| min x1 x2 .. max x1 x2 |] 
        |> Array.map (fun x -> (x, y1))
        |> Some
      else None)

let linesFullAll = 
  // expand each horizontal, vertical or diagonal line
  linesEndpoints
  |> Array.map (fun ((x1, y1), (x2, y2)) ->
      if x1 = x2 then 
        [| min y1 y2 .. max y1 y2 |] 
        |> Array.map (fun y -> (x1, y))
      else if y1 = y2 then
        [| min x1 x2 .. max x1 x2 |] 
        |> Array.map (fun x -> (x, y1))
      else 
        // this bit is annoying! 
        if (x1 < x2 && y1 < y2) || (x1 > x2 && y1 > y2) then
          ([| min x1 x2 .. max x1 x2 |], [| min y1 y2 .. max y1 y2 |]) 
          ||> Array.zip 
        else if (x1 < x2 && y1 > y2) then
          ([| x1 .. x2 |], [| y1 .. -1 .. y2 |]) 
          ||> Array.zip 
        else 
          ([| x1 .. -1 .. x2 |], [| y1 .. y2 |]) 
          ||> Array.zip           
      )

let countOverlaps lines = 
  Array.concat lines
  |> Array.countBy id
  |> Array.filter (fun (point, n) -> n >= 2)
  |> Array.length

// part 1
countOverlaps linesFull  
// part 2
countOverlaps linesFullAll