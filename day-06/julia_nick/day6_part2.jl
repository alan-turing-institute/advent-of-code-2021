using DelimitedFiles

function step_day(count_vec)
    num_breeding_fish = count_vec[1]
    for i in 1:8
        count_vec[i] = count_vec[i+1]
    end
    count_vec[9] = num_breeding_fish
    count_vec[7] += num_breeding_fish
    return count_vec
end

function test_step_day()
    test_list = [1,2,3,4,5,6,7,8,9]
    @assert step_day(test_list) == [2,3,4,5,6,7,9,9,1]
end

test_step_day()

function step_multiple_days(fish_countvec, num_days)
    for i in 1:num_days
        println("Processing day ", i, " num_fish is ", sum(fish_countvec))
        fish_list = step_day(fish_countvec)
    end
    return fish_countvec
end

# read input file, note single quotes around the delimiter
input = readdlm("input.txt", ',',Int)
# convert to a column vector
input = vec(input)
# create a vector of counts
vector_of_counts = Int64[]
for i in 0:8
    push!(vector_of_counts, count(x->(x==i), input))
end


# step 256 days
output = step_multiple_days(vector_of_counts, 256)
print("number of fish is ", sum(output))
