using DelimitedFiles

function calculate_cost(position, start_pos)
    return sum(1:abs(position-start_pos))
end

function test_calculate_cost()
    @assert calculate_cost(5, 16) == 66
    @assert calculate_cost(5, 1) == 10
end

test_calculate_cost()

function calculate_total_cost(position, position_vec)
    diff_vec = map(x->calculate_cost(position,x), position_vec)
    return sum(diff_vec)
end

function test_calculate_total_cost()
    test_list = [16,1,2,0,4,2,7,1,2,14]
    @assert calculate_total_cost(5, test_list) == 168
    @assert calculate_total_cost(2, test_list) == 206
end

test_calculate_total_cost()

# read input file, note single quotes around the delimiter
input = readdlm("input.txt", ',',Int)
# convert to a column vector
input = vec(input)

min_cost = typemax(Int)
min_cost_position = 0
for i in minimum(input):maximum(input)
    cost = calculate_total_cost(i, input)
    if cost < min_cost
        global min_cost = cost
        global min_cost_position = i
    end
end

println("Best position ", min_cost_position, " cost ", min_cost)
