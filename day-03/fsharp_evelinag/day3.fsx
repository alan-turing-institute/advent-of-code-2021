
let input = "00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010"       .Split "\n"


let values = 
//  input 
  System.IO.File.ReadAllLines "day-03/fsharp_evelinag/day3_input.txt"

let countBits (values : string []) position =
  values
  |> Array.countBy (fun vs -> vs.[position])
  |> Map    // for easy reference

let mostCommonBit (values: string []) position = 
  countBits values position
  |> fun ns -> if ns.['1'] >= ns.['0'] then "1" else "0"

let leastCommonBit (values: string []) position = 
  countBits values position
  |> fun ns -> if ns.['0'] <= ns.['1'] then "0" else "1"


let gammaBinary = 
  [| 0..values.[0].Length-1 |]
  |> Array.map (mostCommonBit values)
  |> String.concat ""

let epsilonBinary = 
  gammaBinary 
  |> Seq.map (fun b -> if b = '1' then "0" else "1") 
  |> String.concat ""

let binaryToInt binary = System.Convert.ToInt32(binary, 2)

let gamma = binaryToInt gammaBinary
let epsilon = binaryToInt epsilonBinary

epsilon * gamma

// part 2

let rec filter (bitCriterion: string [] -> int -> string) position (values: string[])  = 
  if values.Length = 1 then
    values 
    |> Array.exactlyOne
    |> binaryToInt
  else
    let mask = bitCriterion values position |> char
    values 
    |> Array.filter (fun vs -> vs.[position] = mask)
    |> filter bitCriterion (position + 1)

let oxygenGeneratorRating = filter mostCommonBit 0 values
let co2ScrubberRating = filter leastCommonBit 0 values

oxygenGeneratorRating * co2ScrubberRating