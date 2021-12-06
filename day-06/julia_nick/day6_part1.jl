using DelimitedFiles

function step_fish(input_fishnum)
    if input_fishnum == 0
        return 6
    else
        return input_fishnum - 1
    end
end


function step_day(input_list)
    num_fish_to_add = count(x->(x==0), input_list)
    output_list = map(x->step_fish(x), input_list)
    append!(output_list, ones(Int, num_fish_to_add)*8)
    return output_list
end

function test_step_day()
    test_list = [3,2,1]
    @assert step_day(test_list) == [2,1,0]
    test_list = [0,2,1]
    @assert step_day(test_list) == [6,1,0,8]
    test
end


function step_multiple_days(fish_list, num_days)
    for i in 1:num_days
        println("Processing day ", i, " num_fish is ", length(fish_list))
        fish_list = step_day(fish_list)
    end
    return fish_list
end

# read input file, note single quotes around the delimiter
input = readdlm("input.txt", ',',Int)
# convert to a column vector
input = vec(input)

# step 80 days
output = step_multiple_days(input, 80)
print("number of fish is ", length(output))
