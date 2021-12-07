orig_input = readlines("day7.txt")
Init_state = hcat(split.(orig_input,",")...) .|> x -> parse(Int64,x)

# positions = sort(unique(Init_state))
un = unique(Init_state)
positions = sort(collect(minimum(un):maximum(un)))
all_dist = zeros(Int64, size(positions,1), 2)

all_dist[:,1] = positions

# for (ind, pos) in enumerate(positions)
#     all_dist[ind,2] = sum(abs.(Init_state .- all_dist[ind,1]))
# end

# minimum(all_dist[:,2])

minimum([sum(abs.(Init_state .- all_dist[ind,1])) for ind in (positions .+1)])
