open System.IO

let edges = 
  File.ReadAllLines "day-12/fsharp_evelinag/day12_input.txt"
  |> Array.map (fun line -> line.Split "-" |> fun xs -> xs.[0], xs.[1])
  |> Array.collect (fun (x,y) -> [| x,y; y,x |])

let isPossible (x : string,y: string) visited =
  // is it possible to go from x to y?
  if y.[0] >= 'A' && y.[0] <= 'Z' then
    // upercase, it's okay
    true
  else // lowercase
    // was it visited?
    visited |> List.contains y |> not


let rec go traversed remaining current =
  if current = "end" then
    [ current::traversed |> List.rev |> String.concat " " ]
  else 
    remaining
    |> Array.filter (fun (x,y) -> x = current)
    |> Array.map (fun (x,y) -> 
        // possible paths
        if isPossible (x,y) traversed then
          go (current::traversed) remaining y
        else
          [])
    |> List.concat

go [] edges "start"    |> List.length

// part 2

let isPossible2 (x : string,y: string) visited usedUpLowercase =
  // is it possible to go from x to y?
  if y.[0] >= 'A' && y.[0] <= 'Z' then
    // upercase, it's okay
    (usedUpLowercase, true)
  else
    // lowercase
    let wasVisited =  visited |> List.contains y
    if wasVisited && not usedUpLowercase then
      // it's okay to visit again
      (true, true)
    else 
      (usedUpLowercase, not wasVisited)

let rec go2 traversed remaining current usedUpLowercase =
  if current = "end" then
    [ current::traversed |> List.rev |> String.concat " " ]
  else 
    remaining
    |> Array.filter (fun (x,y) -> x = current && y <> "start")
    |> Array.map (fun (x,y) -> 
        // possible paths
        let (usedUpLowercase', possible) = isPossible2 (x,y) traversed usedUpLowercase 
        if possible then
          go2 (current::traversed) remaining y usedUpLowercase'
        else
          [])
    |> List.concat

go2 [] edges "start" false |> List.length