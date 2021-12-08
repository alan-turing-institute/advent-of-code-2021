let input = 
  //"16,1,2,0,4,2,7,1,2,14"
  System.IO.File.ReadAllText("day-07/fsharp_evelinag/day7_input.txt")

let positions = input.Split "," |> Array.map int

let distance1 x1 x2 = abs (x1 - x2)
let distance2 x1 x2 = 
  let n = abs (x1 - x2)
  n * (n + 1)/2

let calculateFuel (distance : int -> int -> int) = 
  [ Array.min positions .. Array.max positions ]
  |> List.map (fun x -> 
      positions |> Array.sumBy (fun p -> distance p x))
  |> List.min

calculateFuel distance1
calculateFuel distance2