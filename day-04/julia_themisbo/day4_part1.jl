input = readlines("day4.txt")

draws = split(input[1], ",") .|> x -> parse(Int64,x)

# Create a 3D array with the cards
A = zeros(Int64,5, 5, Int64((size(input,1)-1)/6))
i,j=1,1
for line in input[3:end]
    if line == ""
        i+=1
        j=1
    else
        A[j,:,i] = split(line).|> x -> parse(Int64,x)
        j+=1
    end
end

# Run the simulation
i=1
stop = 0
check = 0
while stop == 0
    check = draws[i]
    A[findall(x->x==check, A)] .= -1

    keep_ind = 0
    keep_type = 0

    for card in 1:Int64((size(input,1)-1)/6)
        for ind in 1:5
            
            keep_ind = ind
            if all(y->y==-1, A[:,ind,card])
                keep_type = 2
                stop = 1
                keep_card = card
                break
            elseif all(y->y==-1, A[ind,:,card])
                keep_type = 1
                stop = 1
                keep_card = card
                break
            end
        end
    end
    i+=1
end

winner = A[:,:,keep_card]
winner[findall(x->x==-1, winner)] .= 0

sum(winner) * check