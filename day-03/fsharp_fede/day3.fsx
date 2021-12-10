open System.IO
open System

let lines = File.ReadAllLines("input.txt")       
let list = Seq.toList lines
let splitList = List.map  (fun (line: string) -> Seq.toList line ) list 
let intList = List.map (List.map Char.GetNumericValue) splitList

let sum = List.reduce (List.map2 (+)) intList
let max = float(intList.Length)
let gammaBin = List.map(fun x -> if x> max/2.0 then "1" else "0") sum |> String.concat ""
let epsilonBin = List.map(fun x -> if x> max/2.0 then "0" else "1") sum |> String.concat ""
let gamma = Convert.ToInt32(gammaBin, 2);
let epsilon = Convert.ToInt32(epsilonBin, 2);
let score = epsilon*gamma

let rec filterList longList text newList =
    match longList with
     | [] -> newList
     | (line: 'a list) :: tail -> 
     if line.Head = text then 
        let filter = List.tail line
        let potentialNewlist = filter :: newList
        filterList tail text potentialNewlist
     else
        filterList tail text newList

let rec getOx (allList: float list list) (res: float list) (origLength: int) =
     match allList.Length with
     | 1 -> 
        if origLength = res.Length then res
        else 
        let final_res = allList[0] |> List.append res
        final_res
     | _ -> 
     let l = List.reduce (List.map2 (+)) allList
     let max = float(allList.Length)
     let avg = if l[0] >= float(max)/2.0 then 1.0 else 0.0
     let newAvg = res @ [avg]
     let newList = filterList allList avg []
     getOx newList newAvg origLength
    

let rec getScr (allList: float list list) (res: float list) (origLength: int)=
     match allList.Length with
     | 1 -> 
        if origLength = res.Length then res
        else 
        let final_res = allList[0] |> List.append res
        final_res
     | _ -> 
     let l = List.reduce (List.map2 (+)) allList
     let max = float(allList.Length)
     let avg = if l[0] >= float(max)/2.0 then 0.0 else 1.0
     let newAvg = res @ [avg]
     let newList = filterList allList avg []
     getScr newList newAvg origLength

let scoreScr = getScr intList [] intList[0].Length
let scrBin = List.map(fun x -> string x) scoreScr |> String.concat ""
let scr = Convert.ToInt32(scrBin, 2);
printfn "%A" scrBin

let scoreOx = getOx intList [] intList[0].Length
let oxBin = List.map(fun x -> string x) scoreOx |> String.concat ""
let ox = Convert.ToInt32(oxBin, 2);
printfn "%A" ox

let final_score = ox*scr

printfn "%A" final_score