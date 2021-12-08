
function deduce_mapping_from_counts(input_line, pattern_dict, possible_mappings)
    # if the input line contains the patterns for
    # "1", "2", "3", only, we should expect the following
    # counts of the true segments:
    # a: 8 b: 6 c: 8 d: 7 e: 4 f: 9 g: 7
    for encoded_segment in collect("abcdefg")
        if count(x->(x==encoded_segment), input_line) == 4
            possible_mappings[encoded_segment] = "e"
        elseif count(x->(x==encoded_segment), input_line) == 6
            possible_mappings[encoded_segment] = "b"
        elseif count(x->(x==encoded_segment), input_line) == 7
            possible_mappings[encoded_segment] = "dg"
        elseif count(x->(x==encoded_segment), input_line) == 8
            possible_mappings[encoded_segment] = "ac"
        elseif count(x->(x==encoded_segment), input_line) == 9
            possible_mappings[encoded_segment] = "f"
        end
    end
    return possible_mappings
end

function find_intersections(digit, true_pattern, possible_mappings)
    # modify a dictionary such that the value for a given key ('digit') is the
    # intersection between the current value and a new string
    for d in digit
        possible_mappings[d] = join(intersect(possible_mappings[d], true_pattern))
    end
    return possible_mappings
end

function deduce_mapping_from_combinations(input_line, pattern_dict, possible_mappings)
    # just look at 1, 4, 7 and narrow down possible mappings according to what segments
    # are in each of them.
    for digit in split(input_line)
        # sort it alphabetically
        digit = join(sort(collect(digit)))
        if length(digit) == 2  # it's a "1"
            possible_mappings = find_intersections(digit, pattern_dict["1"], possible_mappings)
        elseif length(digit) == 3 # it's a "7"
            possible_mappings = find_intersections(digit, pattern_dict["7"], possible_mappings)
        elseif length(digit) == 4 # it's a "4"
            possible_mappings = find_intersections(digit, pattern_dict["4"], possible_mappings)
        end
    end
    return possible_mappings
end

function cleanup_mappings(possible_mappings)
    ## if we already have enough information to unambiguously decode, but
    ## haven't yet propagated it through the map, do that here.
    for k in keys(possible_mappings)
        if length(possible_mappings[k]) == 1
            continue
        end
        newstring = ""
        for c in possible_mappings[k]
            if (!).(string(c) in values(possible_mappings))
                newstring *= c
            end
        end
        possible_mappings[k] = newstring
    end
    return possible_mappings
end

function deduce_mapping(input_line, pattern_dict)
    # create an initial dict of encoded_segment -> possible_plaintexts
    # that we will then try to disambiguate using two different methods
    possible_mappings_init = Dict('a'=>"abcdefg",
                                  'b'=>"abcdefg",
                                  'c'=>"abcdefg",
                                  'd'=>"abcdefg",
                                  'e'=>"abcdefg",
                                  'f'=>"abcdefg",
                                  'g'=>"abcdefg")
    possible_mappings = deduce_mapping_from_counts(input_line,
                                                   pattern_dict,
                                                   possible_mappings_init)
    possible_mappings = deduce_mapping_from_combinations(input_line,
                                                         pattern_dict,
                                                         possible_mappings)
    # should have all the info there, but need to propagate through the dict
    possible_mappings = cleanup_mappings(possible_mappings)
    return possible_mappings
end


function get_value_string(encoded_digits, reverse_patterns_dict, mapping)
    # use the mapping, and the reverse digit->segments dict, to decode
    # the four numbers in an encoded output.
    output_string = ""
    for encoded_digit in split(encoded_digits)
        pattern_key = ""
        for d in encoded_digit
            pattern_key *= mapping[d]
        end
        # sort into alphabetical order
        pattern_key = join(sort(collect(pattern_key)))
        number = reverse_patterns_dict[pattern_key]
        println("found number ",number)
        output_string *= number
    end
    return output_string
end


function process_row(signal_pattern, encoded_output, pattern_dict)
    # put everything together for a single signal pattern and output
    mapping = deduce_mapping(signal_pattern, pattern_dict)
    patterns_reverse = Dict(value=>key for (key, value) in pattern_dict)
    output_string = get_value_string(encoded_output, patterns_reverse, mapping)
    return parse(Int, output_string)
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

# parse the input into strings
input_lines = readlines("input.txt")

# now go through each line (and pray for the best!)
total = 0
for i in 1:length(input_lines)
    signal_pattern, output = split(input_lines[i],"|")
    global total += process_row(signal_pattern, output, patterns)
end

println("total is ", total)
