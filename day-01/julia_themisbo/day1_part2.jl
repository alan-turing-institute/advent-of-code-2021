# txt = readlines("day1.txt")

# txt = map(x->parse(Int64,x),txt)

# sums = Array{Int64, 1}(undef,size(txt,1)-2)
# for i in 2:(size(txt, 1)-1)
#     sums[i-1] = txt[i-1] + txt[i] + txt[i+1]
# end

# count = 0
# for i in 2:size(sums, 1)
#     if sums[i] > sums[i-1]
#         count += 1
#     end
# end

# print(count)

txt = map(x->parse(Int64,x),readlines("day1.txt"))
sums = [txt[i-1] + txt[i] + txt[i+1] for i in 2:(size(txt, 1)-1)]
sum([1 for i in 2:size(sums, 1) if sums[i] > sums[i-1]])