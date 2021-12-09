
let input = "2199943210
3987894921
9856789892
8767896789
9899965678"   .Split "\n"

let heightmap = 
  //input
  System.IO.File.ReadAllLines "day-09/fsharp_evelinag/day9_input.txt"
  |> Array.map (fun line -> 
      line 
      |> Seq.map (string >> int)
      |> Array.ofSeq)

let height = Array.length heightmap
let width = Array.length heightmap.[0]

let lowPoints, risks =
  ([0 .. height - 1], [0 .. width - 1])
  ||> List.allPairs
  |> List.choose (fun (row, col) ->
      let location = heightmap.[row].[col]
      let adjacent = 
        [ if row > 0 then Some heightmap.[row-1].[col] else None
          if row < height-1 then Some heightmap.[row+1].[col] else None 
          if col > 0 then Some heightmap.[row].[col-1] else None 
          if col < width-1 then Some heightmap.[row].[col+1] else None]
        |> List.choose id
      if (location < List.min adjacent) then
        Some( (row, col), location + 1)
      else 
        None
      )
  |> List.unzip

let riskScore = risks |> List.sum  

// part 2

let getLocalBasin lowPoint =
  // find area that is surrounded only by 9s

  // mutable hash set of visited locations
  let visited = System.Collections.Generic.HashSet<int*int>()
  
  let rec growBasin (i, j) =  
    if heightmap.[i].[j] = 9 
        || visited.Contains (i,j) then 
      []
    else
      visited.Add (i,j) |> ignore
      (i, j) :: [
        if i > 0 then yield! growBasin (i-1, j) 
        if i < height-1 then yield! growBasin (i+1, j) 
        if j > 0 then yield! growBasin (i, j-1) 
        if j < width-1 then yield! growBasin (i, j+1) ]

  growBasin lowPoint

let basins = 
  lowPoints
  |> List.map (fun point -> getLocalBasin point |> List.length)
  |> List.sortDescending
  |> List.take 3
  |> List.fold (*) 1

