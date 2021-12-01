# txt = readlines("test_day1.txt")

# txt = map(x->parse(Int64,x),txt)

# count = 0
# for i in 2:size(txt, 1)
#     if txt[i] > txt[i-1]
#         count += 1
#     end
# end

# print(count)

txt = map(x->parse(Int64,x),readlines("day1.txt"))
sum([1 for i in 2:size(txt, 1) if txt[i] > txt[i-1]])