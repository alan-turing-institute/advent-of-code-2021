let input = 
  //"3,4,3,1,2"
  System.IO.File.ReadAllText "day-06/fsharp_evelinag/day6_input.txt"

let initialGeneration = 
  input
  |> fun s -> s.Split ","
  |> Array.map int

// inefficient part 1

let fishStep timer =
  if timer = 0 then
    [| 8; 6 |]
  else 
    [| timer - 1 |]

let step generation =
  generation
  |> Array.collect fishStep

let rec countFish n generation =
  if n = 0 then
    generation |> Array.length
  else
    generation 
    |> step
    |> countFish (n-1) 

countFish 80 initialGeneration    

// hahaha - no
// countFish 256 initialGeneration

// ----------------------------------------------
// Let's switch representation

// array of how many fish of each age do I have in the pool
let initialTimes = 
  Array.init 9 (fun age ->
    initialGeneration 
    |> Array.filter ( (=) age )
    |> Array.length
    |> int64)

let step' (timeToSpawn : int64 []) =
  let timeToSpawn' =
    Array.init 9 (fun age -> timeToSpawn.[(age + 1) % 9])
  timeToSpawn'.[6] <- timeToSpawn'.[6] + timeToSpawn.[0]
  timeToSpawn'

let rec countFish' n generation =
  if n = 0 then
    generation |> Array.sum
  else
    generation 
    |> step'
    |> countFish' (n-1) 

countFish' 256 initialTimes     