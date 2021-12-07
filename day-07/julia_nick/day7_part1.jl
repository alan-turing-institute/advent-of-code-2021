using DelimitedFiles

function calculate_cost(position, position_vec)
    diff_vec = map(x->abs(x - position), position_vec)
    return sum(diff_vec)
end

function test_calculate_cost()
    test_list = [16,1,2,0,4,2,7,1,2,14]
    @assert calculate_cost(2, test_list) == 37
    @assert calculate_cost(1, test_list) == 41
    @assert calculate_cost(3, test_list) == 39
    @assert calculate_cost(10, test_list) == 71
end

test_calculate_cost()

# read input file, note single quotes around the delimiter
input = readdlm("input.txt", ',',Int)
# convert to a column vector
input = vec(input)

min_cost = typemax(Int)
min_cost_position = 0
for i in minimum(input):maximum(input)
    cost = calculate_cost(i, input)
    if cost < min_cost
        global min_cost = cost
        global min_cost_position = i
    end
end

println("Best position ", min_cost_position, " cost ", min_cost)
