
function is_horizontal_or_vertical(startx, starty, endx, endy)
    return (startx==endx) || (starty == endy)
end

function test_is_horizontal_or_vertical()
    @assert is_horizontal_or_vertical(3,4,3,7)
    @assert is_horizontal_or_vertical(2,4,3,4)
    @assert !is_horizontal_or_vertical(1,2,3,4)
end


test_is_horizontal_or_vertical()

function draw_diagonal_line(grid, startx, starty, endx, endy)
    if (endx > startx) && (endy > starty) # up-right line
        for i in 0:(endx-startx)
            grid[startx+i, starty+i] += 1
        end
    elseif (endx > startx) && (endy < starty) # down-right line
        for i in 0:(endx-startx)
            grid[startx+i, starty-i] += 1
        end
    elseif (endx < startx) && (endy < starty) # down-left line
        for i in 0:(startx-endx)
            grid[startx-i, starty-i] += 1
        end
    elseif (endx < startx) && (endy > starty) # up-left line
        for i in 0:(startx-endx)
            grid[startx-i, starty+i] += 1
        end
    end
    return grid
end


function test_draw_diagonal_line()
    grid = zeros(Int, 5, 5)
    grid = draw_diagonal_line(grid, 1, 1, 3, 3)
    @assert grid[2,2] == 1
    @assert sum(grid) == 3
    grid = draw_diagonal_line(grid, 3, 1, 1, 3)
    @assert grid[2,2] == 2
    @assert sum(grid) == 6
    grid = zeros(Int, 5, 5)
    grid = draw_diagonal_line(grid, 3, 5, 5, 3)
    @assert grid[4,4] == 1
    @assert sum(grid) == 3
    grid = draw_diagonal_line(grid, 5, 5, 3, 3)
    @assert grid[4,4] == 2
    @assert sum(grid) == 6
end

test_draw_diagonal_line()


function draw_grid(startxs, startys, endxs, endys)
    xmax = maximum([maximum(startxs), maximum(endxs)])
    ymax = maximum([maximum(startys), maximum(endys)])
    grid =  zeros(Int, xmax, ymax)
    # assume all arrays are same length
    for i in 1:length(startxs)
        if is_horizontal_or_vertical(startxs[i],
                                       startys[i],
                                       endxs[i],
                                       endys[i])
            for ix in minimum([startxs[i], endxs[i]]):maximum([startxs[i], endxs[i]])
                for iy in minimum([startys[i], endys[i]]):maximum([startys[i], endys[i]])
                    grid[ix,iy] += 1
                end
            end
        else
            # diagonal line
            grid = draw_diagonal_line(grid, startxs[i], startys[i], endxs[i], endys[i])
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
