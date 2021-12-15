open System.IO
open System.Collections.Generic

let initial, rules = 
  File.ReadAllText "day-14/fsharp_evelinag/day14_input.txt"
  |> fun s -> s.Split "\n\n" |> fun a -> 
      "^" + a.[0] + "$", 
      a.[1].Split "\n" |> Array.map (fun r -> r.Split " -> " |> fun rs -> rs.[0], rs.[1])

let letters = 
  rules 
  |> Array.map (fun (x,y) -> x + y)
  |> Array.fold (+) initial
  |> Seq.distinct

let allRules = 
  letters
  |> Seq.allPairs letters
  |> Seq.map (fun (x, y) -> 
      let result = 
        rules
        |> Array.choose (fun (a,b) -> if (a = string x + string y) then Some b else None )
      if result.Length = 1 then
        (x, y), [ (x, result.[0].[0]); (result.[0].[0], y)]
      else 
        (x, y), [ (x, y)]
      )
  |> Seq.append (letters |> Seq.map (fun l -> ('^', l), [ ('^', l) ]))
  |> Seq.append (letters |> Seq.map (fun l -> (l, '$'), [ (l, '$') ]))
  |> Map

let bigrams = letters |> Seq.allPairs letters |> Array.ofSeq

let initialCounts =
  Array.init bigrams.Length (fun i -> 
    (bigrams.[i], 
      initial
      |> Seq.pairwise 
      |> Seq.sumBy (fun (x, y) -> if fst bigrams.[i] = x && snd bigrams.[i] = y then 1L else 0L)))
  |> Map

let state = initialCounts

let rec applyRules iter (state: Map<char*char, int64>) =
  if iter = 0 then 
    state
  else 
    let state' =
      state
      |> Seq.map (fun (KeyValue(bigram, count)) ->
          allRules.[bigram] |> List.map (fun x -> count, x) |> Array.ofList)
      |> Array.concat
      |> Array.groupBy snd
      |> Array.map (fun (bigram, counts) -> bigram, counts |> Array.sumBy fst)
      |> Map

    applyRules (iter - 1) state'

let countLetter (state: Map<char*char,int64>) l = 
  bigrams
  |> Seq.sumBy (fun bigram ->
      if state.ContainsKey bigram then
        if fst bigram = l || snd bigram = l then 
          if fst bigram = snd bigram then
            2L * state.[bigram]
          else
            state.[bigram] 
        else 
          0L
      else 0L)
  |> fun n -> l, n/2L

let getDifference (result : Map<char*char, int64>)= 
  letters 
  |> Seq.map (countLetter result)
  |> Array.ofSeq
  |> Array.map snd
  |> Array.filter ((<) 0L)
  |> fun ns -> Array.max ns - Array.min ns

let result1 = applyRules 10 initialCounts
getDifference result1

let result2 = applyRules 40 initialCounts
getDifference result2