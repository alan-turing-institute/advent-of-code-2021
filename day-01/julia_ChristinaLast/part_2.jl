using DelimitedFiles


function sum_sliding_window(depths, i)
  depths[i] + depths[i+1] + depths[i+2]
end

no_of_depth_increases = 0

depths = readdlm("input.txt", '\n', Int)
  for i = 2:length(depths)-2 # to avoid index error
    if sum_sliding_window(depths, i) > sum_sliding_window(depths, i-1)
      global no_of_depth_increases += 1
    end
  end
return no_of_depth_increases

print("Total Number of depth increases is: ", no_of_depth_increases)