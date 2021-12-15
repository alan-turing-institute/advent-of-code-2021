
open System.IO

let coordinates, instructions =
  File.ReadAllText "day-13/fsharp_evelinag/day13_input.txt"
  |> fun s -> s.Split "\n\n"
  |> fun xs ->
      xs.[0].Split "\n" 
        |> Array.map (fun ys -> 
            ys.Split ","  
            |> fun values -> 
                int values.[0], int values.[1]),
      xs.[1].Split "\n"
        |> Array.map (fun instr -> 
            instr.Split "="
            |> fun s -> s.[0].[s.[0].Length-1], int s.[1])

let print paper =
  paper
  |> Array.iter (fun line ->
    printf "|"
    line |> Array.iter (printf "%c")
    printfn "|")

let paper = 
  let maxX = coordinates |> Array.map fst |> Array.max
  let maxY = coordinates |> Array.map snd |> Array.max
  Array.init (maxY + 1) (fun y ->
    Array.init (maxX + 1) (fun x ->
      if coordinates |> Array.contains (x,y) then 'X' else ' '))

//print paper

let fold (paper: char [][]) instruction = 
  let axis, n = instruction
  if axis = 'x' then
    Array.init paper.Length (fun y ->
      Array.init n (fun x ->
        let value1 = paper.[y].[x]
        let value2 = paper.[y].[n - (x - n)]
        if value1 = 'X' || value2 = 'X' then 'X' else ' '
        ))
  else
    Array.init n (fun y ->
      Array.init paper.[y].Length (fun x ->        
        let value1 = paper.[y].[x]
        let value2 = paper.[n - (y - n)].[x]
        if value1 = 'X' || value2 = 'X' then 'X' else ' '))

let count folded = 
  folded 
  |> Array.sumBy (fun line -> line |> Array.sumBy (fun x -> if x = 'X' then 1 else 0))

fold paper instructions.[0] |> count


let foldAll paper instructions =
  (paper, instructions)
  ||> Array.fold (fun p instr -> fold p instr)

let folded = foldAll paper instructions
folded |> print  

