all_lines = readlines("day8.txt")
all_lines_vec = hcat(split.(all_lines," | ")...)

outputs = all_lines_vec[2,:]

output_vales = hcat(split.(outputs," ")...)

lenghts = length.(output_vales)

ones = lenghts .== 2
fours = lenghts .== 4
sevens = lenghts .== 3
eights = lenghts .== 7

vals_1478 = ones + fours + sevens + eights
sum(vals_1478)