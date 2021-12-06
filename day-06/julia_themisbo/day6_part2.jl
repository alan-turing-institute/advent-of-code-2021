orig_input = readlines("day6.txt")
Init_state = hcat(split.(orig_input,",")...) .|> x -> parse(Int64,x)

Init_freq = unique([[j,count(x->x==j,Init_state)] for j in Init_state])

days = 256
all_freqs = zeros(Int64, 9, 2, days+1)
all_freqs[:,1,:] .= collect(0:8)

for freq in Init_freq
    all_freqs[freq[1]+1,2,1] = freq[2]
end

all_freqs[:,:,1]

for day in 1:days
    all_freqs[:,:,day+1] = all_freqs[:,:,day]
    newborns = all_freqs[1,2,day+1]
    for ii in 2:9
        all_freqs[ii-1,2,day+1] = all_freqs[ii,2,day+1]
    end
    all_freqs[7,2,day+1] += newborns
    all_freqs[9,2,day+1] = newborns
end

sum(all_freqs[:,2,end])