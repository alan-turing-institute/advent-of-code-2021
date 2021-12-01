

let input' = "199
200
208
210
200
207
240
269
260
263" 

let parse (input: string) = 
  input.Split "\n" 
  |> Array.filter ((<>) "")
  |> Array.map int

let depths = 
  System.IO.File.ReadAllText "day-01/fsharp_evelinag/day1_input.txt"
  //input'
  |> parse

let increases depths = 
  depths
  |> Array.pairwise
  |> Array.sumBy (fun (x1, x2) -> if x2 > x1 then 1 else 0)

let answer1 = increases depths

let answer2 = 
  depths
  |> Array.windowed 3
  |> Array.map (Array.sum)
  |> increases
