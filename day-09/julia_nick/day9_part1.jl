

function read_input(input_filename)
    lines = readlines(input_filename)
    grid = zeros(Int, length(lines), length(lines[1]))
    for iy in 1:length(lines)
        for ix in 1:length(lines[iy])
            grid[iy, ix] = parse(Int, lines[iy][ix])
        end
    end
    return grid
end

function is_local_minimum(x, y, grid)
#    local_min_x = false
    if x == 1
        local_min_x = (grid[x,y] < grid[x+1,y])
    elseif x == size(grid)[1]
        local_min_x = (grid[x,y] < grid[x-1,y])
    else
        local_min_x = (grid[x,y] < grid[x+1,y]) && (grid[x,y] < grid[x-1,y])
    end
#    local_min_y = false
    if y == 1
        local_min_y = (grid[x,y] < grid[x,y+1])
    elseif y == size(grid)[2]
        local_min_y = (grid[x,y] < grid[x,y-1])
    else
        local_min_y = (grid[x,y] < grid[x,y+1]) && (grid[x,y] < grid[x,y-1])
    end
    return (local_min_x && local_min_y)
end

function find_all_local_minima(grid)
    minima_coords = []
    for ix in 1:size(grid)[1]
        for iy in 1:size(grid)[2]
            if is_local_minimum(ix, iy, grid)
                push!(minima_coords,(ix,iy))
            end
        end
    end
    return minima_coords
end


function get_total_risk(grid)
    minima = find_all_local_minima(grid)
    total = 0
    for minimum in minima
        total += grid[minimum[1],minimum[2]] + 1
    end
    return total
end
