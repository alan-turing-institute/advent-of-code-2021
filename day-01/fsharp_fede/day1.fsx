open System.IO

let lines = File.ReadAllLines("input.txt")       
let intList = Seq.toList lines 
            |> Seq.map int

let seqWindows = Seq.windowed 2 intList

// ok, i have tried 200 times but i haven't found the proper way  
// of doing this using sumBy or well, that single line operation instead of this for loop

let mutable x = 0

for item in seqWindows do
    let i = if item[1] - item[0]>0 then 1 else 0
    x <- x + i

printfn "%i" x

let threeGroup = Seq.windowed 3 intList
let seqSum = Seq.map Array.sum threeGroup
let pairs = Seq.windowed 2 seqSum

// once again I am here and i haven't figured out how to do this last step properly
let mutable y = 0
for item in pairs do
    let i = if item[1] - item[0]>0 then 1 else 0
    y <- y + i

printfn "%i" y