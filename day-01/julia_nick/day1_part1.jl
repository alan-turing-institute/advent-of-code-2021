using DelimitedFiles

inputs = readdlm("input.txt", '\n', Int)
bigger_count = 0
for i in 2:size(inputs)[1]
    if inputs[i] > inputs[i-1]
        global bigger_count += 1
    end
end

print("Number of increases ",bigger_count)
