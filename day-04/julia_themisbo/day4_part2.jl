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
dims_left = collect(1:size(A,3))
while stop == 0
    
    check = draws[i]
    A[findall(x->x==check, A)] .= -1
    dims = size(A,3)

    if size(dims_left,1) == 1
        for ind in 1:5
            if all(y->y==-1, A[:,ind,dims_left])
                stop = 1
            elseif all(y->y==-1, A[ind,:,dims_left])
                stop = 1
            end
        end
    else    for card in 1:dims
                for ind in 1:5
                    keep_ind = ind
                    if all(y->y==-1, A[:,ind,card])
                        A[:,:,card] .= -2
                        setdiff!(dims_left, card)
                    elseif all(y->y==-1, A[ind,:,card])
                        A[:,:,card] .= -2
                        setdiff!(dims_left, card) 
                    end
                end
            end
        i+=1
    end
end

loser = A[:,:,dims_left]
loser[findall(x->x==-1, loser)] .= 0

sum(loser) * check