using DelimitedFiles


function calc_window_sum(inputvals, index)
    inputvals[index] + inputvals[index+1] + inputvals[index+2]
end


inputs = readdlm("input.txt", '\n', Int)
bigger_count = 0
for i in 2:size(inputs)[1]-2
    if calc_window_sum(inputs,i) > calc_window_sum(inputs,i-1)
        global bigger_count += 1
    end
end

print("Number of increases ",bigger_count)
