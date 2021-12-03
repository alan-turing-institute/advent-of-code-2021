
function binary_string_to_decimal(binstring)
    total = 0
    num_bits = length(binstring)
    for i in 1:num_bits
        if binstring[i] == '1'
            total += 2^(num_bits-i)
        end
    end
    total
end

# given an array of binary strings, count whether there are
# more '1's or '0's (or equal) at a given position in the string
function most_common_bit_per_position(input_array, position)
    # return '1' if more ones, or '0' if more zeros, or 'e' if equal
    zero_count = 0
    one_count = 0
    for row in input_array
        if row[position] == '1'
            one_count += 1
        else
            zero_count += 1
        end
    end
    if one_count > zero_count
        return '1'
    elseif zero_count > one_count
        return '0'
    else
        return 'e'
    end
end

# see if we keep a given row, based on conditions for oxygen or co2 filters
# by comparing a bit with the most common bit in that position.
function filter_row(bit, most_common, mode)
    # mode can be 'oxygen' or 'CO2'
    if mode == "oxygen"
        if (bit == most_common) ||
            ((most_common == 'e') && (bit == '1'))
            return true
        else
            return false
        end
    else # CO2
        if most_common == 'e'
            if bit == '0'
                return true
            end
        elseif (bit != most_common)
            return true
        end
    end
    return false
end

# recursive function to filter the list of binary digits down
function filter_by_most_common_bit(input_array, position, mode)
    # mode can be 'oxygen' or 'CO2'
    # position is where we are in the binary string,
    # e.g. for position=4 we are looking at the 4th bit.
    println("Checking position ",position, " for ",mode, ", have ",size(input_array), " rows")

    # loop over input_array, and put selected rows into filtered_array
    filtered_array = []
    for row in input_array
        most_common =  most_common_bit_per_position(input_array, position)
        if filter_row(row[position], most_common, mode)
            push!(filtered_array, row)
        end
    end
    # check if we can break out of the recursion loop
    if (size(filtered_array)[1] == 1)
        return filtered_array
    end
    # if not, move to next position
    filter_by_most_common_bit(filtered_array, position+1, mode)
end


# read the input data into an array (strips newlines for us)
rows = readlines("input.txt")

# get the oxygen and CO2 ratings
# the recursive 'filter_by_most_common_bit' function
# should return a one-element array
oxygen_binary = filter_by_most_common_bit(rows, 1, "oxygen")
co2_binary = filter_by_most_common_bit(rows, 1, "CO2")

if size(oxygen_binary)[1] != 1
    println("Something went wrong filtering for oxygen! ",size(oxygen_binary))
end
if size(co2_binary)[1] != 1
    println("Something went wrong filtering for CO2! ",size(co2_binary))
end

println("oxygen ", oxygen_binary)
println("CO2 ", co2_binary)

# convert to decimal
oxygen_dec = binary_string_to_decimal(oxygen_binary[1])
co2_dec = binary_string_to_decimal(co2_binary[1])
println("oxygen (decimal) ",oxygen_dec)
println("CO2 (decimal) ",co2_dec)

# multiply
println("total life support ",oxygen_dec * co2_dec)
