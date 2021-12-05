orig_input = readlines("day5.txt")
input = split.(orig_input)

x1 = zeros(Int64,size(input,1))
x2 = zeros(Int64,size(input,1))
y1 = zeros(Int64,size(input,1))
y2 = zeros(Int64,size(input,1))

for (ind,line) in enumerate(orig_input)
    whole = split(line)
    x1[ind], y1[ind] = split(whole[1], ",").|> x -> parse(Int64,x)
    x2[ind], y2[ind] = split(whole[3], ",").|> x -> parse(Int64,x)
end

minx = minimum(vcat(x1,x2))
maxx = maximum(vcat(x1,x2))

miny = minimum(vcat(y1,y2))
maxy = maximum(vcat(y1,y2))

x1 .+= (1-minx)
x2 .+= (1-minx)
y1 .+= (1-miny)
y2 .+= (1-miny)

matdim = maximum([size(collect(minx:maxx),1),size(collect(miny:maxy),1)])

bigmat = zeros(Int64,matdim,matdim)

iters = size(x1,1)

for i in 1:iters
    if (x1[i] == x2[i])
        sorted = sort([y1[i],y2[i]])
        bigmat[sorted[1]:sorted[2],x1[i]] .+= 1
    elseif (y1[i] == y2[i])
        sorted = sort([x1[i],x2[i]])
        bigmat[y1[i],sorted[1]:sorted[2]] .+= 1
    elseif (x1[i] + y2[i]) == (x2[i] + y1[i])
        sorted_x = sort([x1[i],x2[i]])
        sorted_y = sort([y1[i],y2[i]])
        for (indj, j) in enumerate(sorted_x[1]:sorted_x[2])
            bigmat[sorted_y[1]+indj-1,j] += 1
        end
    elseif (x1[i] + y1[i]) == (x2[i] + y2[i])
        sorted_x = sort([x1[i],x2[i]])
        sorted_y = sort([y1[i],y2[i]])
        for (indj, j) in enumerate(sorted_x[1]:sorted_x[2])
            bigmat[sorted_y[2] + 1 - indj,j] += 1
        end
    end
end 

sum(map(x->x.>=2,bigmat))