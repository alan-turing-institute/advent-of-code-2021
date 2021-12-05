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
printf "%i" score



