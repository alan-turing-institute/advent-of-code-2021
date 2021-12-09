

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
    if x == 1
        local_min_x = (grid[x,y] < grid[x+1,y])
    elseif x == size(grid)[1]
        local_min_x = (grid[x,y] < grid[x-1,y])
    else
        local_min_x = (grid[x,y] < grid[x+1,y]) && (grid[x,y] < grid[x-1,y])
    end
    if y == 1
        local_min_y = (grid[x,y] < grid[x,y+1])
    elseif y == size(grid)[2]
        local_min_y = (grid[x,y] < grid[x,y-1])
    else
        local_min_y = (grid[x,y] < grid[x,y+1]) && (grid[x,y] < grid[x,y-1])
    end
    return (local_min_x && local_min_y)
end

function find_basin_coords(x, y, grid, basin_coords)
    # basin coords is a set
    # recursive function walks in all directions and adds coords to list
    # if : value at new grid square is not 9, AND new grid square isn't already in set,
    # AND new grid square is not off the ends of the grid.
    if grid[x,y] != 9
        push!(basin_coords, (x, y))
    end
    if ((x-1) in 1:size(grid)[1]) && (grid[x-1,y] != 9) && (!).(in((x-1,y),basin_coords))

        basin_coords = find_basin_coords(x-1, y, grid, basin_coords)
    end
    if ((x+1) in 1:size(grid)[1]) && (grid[x+1,y] != 9)  && (!).(in((x+1,y),basin_coords))
        basin_coords = find_basin_coords(x+1, y, grid, basin_coords)
    end
    if ((y-1) in 1:size(grid)[2]) && (grid[x,y-1] != 9)  && (!).(in((x,y-1),basin_coords))
        basin_coords = find_basin_coords(x, y-1, grid, basin_coords)
    end
    if ((y+1) in 1:size(grid)[2]) && (grid[x,y+1] != 9) && (!).(in((x,y+1),basin_coords))
        basin_coords = find_basin_coords(x, y+1, grid, basin_coords)
    end
    return basin_coords
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


function find_all_basin_sizes(grid)
    minima = find_all_local_minima(grid)
    basin_sizes = []
    for minimum in minima
        basin_coordinates = Set([])
        push!(basin_sizes, length(find_basin_coords(minimum[1], minimum[2],grid, basin_coordinates)))
    end
    return sort(basin_sizes, rev=true)

end


grid = read_input("input.txt")
basin_sizes = find_all_basin_sizes(grid)
answer = prod(basin_sizes[1:3])
println("answer is ",answer)
