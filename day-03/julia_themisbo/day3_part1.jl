input = (split.(readlines("day3.txt"),""))
input_mat = hcat(input...) .|> x -> parse(Int64,x)

function get_rate(rate)
    keep = zeros(Int64,size(input_mat)[1])

    for i in 1:size(input_mat)[1]
        # println(i)
        dd = [[j,count(x->x==j,input_mat[i,:])] for j in u]
        # println(dd)
        ddd = hcat(dd...)
        if rate == "gamma"
            keep[i] = ddd[1,argmax(ddd[2,:])]
        elseif rate == "epsilon"
            keep[i] = ddd[1,argmin(ddd[2,:])]
        end
    end
    return "0b"*join(keep) |> x -> parse(Int64,x)
end

get_rate("gamma")*get_rate("epsilon")