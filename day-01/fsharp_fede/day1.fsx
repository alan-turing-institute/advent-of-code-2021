open System.IO

let lines = File.ReadAllLines("input.txt")       
let intList = Seq.toArray lines 
            |> Array.map int

let seqWindows = Array.windowed 2 intList
let countOne = seqWindows |> Array.map (fun x -> if x[1]-x[0]>0 then 1 else 0) |> Array.sum

printfn "%A" countOne

let threeGroup = Array.windowed 3 intList
let seqSum = Array.map Array.sum threeGroup
let pairs = Array.windowed 2 seqSum

let countTwo = pairs |> Array.map (fun x -> if x[1]-x[0]>0 then 1 else 0) |> Array.sum

printfn "%i" countTwo
