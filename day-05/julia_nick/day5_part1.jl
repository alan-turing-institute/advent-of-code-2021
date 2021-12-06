
function is_horizontal_or_vertical(startx, starty, endx, endy)
    return (startx==endx) || (starty == endy)
end

function test_is_horizontal_or_vertical()
    @assert is_horizontal_or_vertical(3,4,3,7)
    @assert is_horizontal_or_vertical(2,4,3,4)
    @assert !is_horizontal_or_vertical(1,2,3,4)
end


test_is_horizontal_or_vertical()

function draw_grid(startxs, startys, endxs, endys)
    xmax = maximum([maximum(startxs), maximum(endxs)])
    ymax = maximum([maximum(startys), maximum(endys)])
    grid =  zeros(Int, xmax, ymax)
    # assume all arrays are same length
    for i in 1:length(startxs)
        if ! is_horizontal_or_vertical(startxs[i],
                                       startys[i],
                                       endxs[i],
                                       endys[i])
            continue
        end

        for ix in minimum([startxs[i], endxs[i]]):maximum([startxs[i], endxs[i]])
            for iy in minimum([startys[i], endys[i]]):maximum([startys[i], endys[i]])
                grid[ix,iy] += 1
            end
        end
    end
    return grid
end




inputs = readlines("input.txt")

starts = map(x->split(x)[1], inputs)
ends = map(x->split(x)[3], inputs)

startxs = map(x->parse(Int,split(x,",")[1]), starts)
startys = map(x->parse(Int, split(x,",")[2]), starts)
endxs = map(x->parse(Int, split(x,",")[1]), ends)
endys = map(x->parse(Int, split(x,",")[2]), ends)

grid = draw_grid(startxs, startys, endxs, endys)

overlaps = count(x->(x>1), grid)
print("Count of overlaps ", overlaps)
