

function count_unambiguous_digits(text_list, digit_list, pattern_dict)

    digit_counts = Dict((i, 0) for i in digit_list)
#    targets = Dict((length(pattern_dict[i]),i) for i in digit_list)
    # text list is a list of space separated strings
    for line in text_list
        lengths = [length(i) for i in split(line)]
        for digit in keys(digit_counts)
            digit_counts[digit] += count(x->x==length(pattern_dict[digit]), lengths)
        end
    end
    return digit_counts
end


patterns = Dict("0"=>"abcefg",
                "1"=>"cf",
                "2"=>"acdeg",
                "3"=>"acdfg",
                "4"=>"bcdf",
                "5"=>"abdfg",
                "6"=>"abdefg",
                "7"=>"acf",
                "8"=>"abcdefg",
                "9"=>"abcdfg")

pattern_length = Dict((i, length(patterns[i])) for i in keys(patterns))

input_lines = readlines("input.txt")


signal_patterns = map(line->split(line, "|")[1], input_lines)
outputs = map(line->split(line, "|")[2], input_lines)


count_dict = count_unambiguous_digits(outputs, ["1","4","7","8"], patterns)
println("Count dict ", count_dict)
answer = sum(values(count_dict))
println("total is ",answer)
