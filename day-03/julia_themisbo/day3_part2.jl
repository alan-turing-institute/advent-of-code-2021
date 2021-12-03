
function get_rating(rating)
    input = (split.(readlines("day3.txt"),""))
    input_mat = hcat(input...) .|> x -> parse(Int64,x)

    for i in 1:(size(input_mat)[1])
        dd = [[j,count(x->x==j,input_mat[i,:])] for j in u]
        ddd = hcat(dd...)
        if rating == "oxygen"
            if all(y->y==ddd[2,1],ddd[2,:])
                inds = 1
            else inds = ddd[1,argmax(ddd[2,:])]
            end
        elseif rating == "CO2"
            if all(y->y==ddd[2,1],ddd[2,:])
                inds = 0
            else inds = ddd[1,argmin(ddd[2,:])]
            end
        end
        input_mat = input_mat[:,input_mat[i,:] .== inds]
        if size(input_mat)[2] == 1 
            break
        end
    end
    return "0b"*join(input_mat) |> x -> parse(Int64,x)
end


get_rating("oxygen")*get_rating("CO2")