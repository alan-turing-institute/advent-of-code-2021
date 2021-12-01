using DelimitedFiles

no_of_depth_increases = 0
depths = readdlm("input.txt", '\n', Int)
  for i = 2:length(depths)
    if depths[i] > depths[i-1]
      global no_of_depth_increases += 1
    end
  end
return no_of_depth_increases

print("Total Number of depth increases is: ", no_of_depth_increases)