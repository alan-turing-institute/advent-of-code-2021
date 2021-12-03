
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

# read the input data into an array (strips newlines for us)
rows = readlines("input.txt")

# how many binary digits in each row
num_digits = length(rows[1])
# initialize arrays to count ones and zeros
one_counts = zeros(num_digits)
zero_counts = zeros(num_digits)
# count ones and zeros in each position
for row in rows
    for i in 1:num_digits
        if row[i] == '1' # has to be single quotes !?
            one_counts[i] += 1
        else
            zero_counts[i] += 1
        end
    end
end
println("zero counts", zero_counts)
println("one counts", one_counts)

# now construct binary strings depending on whether there were
# more ones or zeros in each position
gamma_rate = ""
epsilon_rate = ""

for i in 1:num_digits
    if one_counts[i] > zero_counts[i]
        global gamma_rate *= "1"
        global epsilon_rate *= "0"
    else # what if they're equal??? never mind....
        global epsilon_rate *= "1"
        global gamma_rate *= "0"
    end
end

println("gamma rate ", gamma_rate)
println("epsilon rate ", epsilon_rate)

# convert to decimal
gamma_rate_dec = binary_string_to_decimal(gamma_rate)
epsilon_rate_dec = binary_string_to_decimal(epsilon_rate)
println("gamma rate (decimal) ",gamma_rate_dec)
println("epsilon rate (decimal) ",epsilon_rate_dec)

# multiply
println("total power consumption ",gamma_rate_dec * epsilon_rate_dec)
