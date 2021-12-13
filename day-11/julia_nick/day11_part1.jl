

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

function find_neighbours(coords, grid)
    neighbours = []
    for xdiff in -1:1
        for ydiff in -1:1
            if ((xdiff == 0) && (ydiff ==0) ||
                (((coords[1] + xdiff) in 1:size(grid)[1]) == false) ||
                (((coords[2] + ydiff) in 1:size(grid)[2]) == false))
                continue
            end
            push!(neighbours, CartesianIndex(coords[1]+xdiff, coords[2]+ydiff))
        end
    end
    return neighbours
end

function flash(coords, grid, flash_count)
    flash_count += 1
    grid[coords] = 0
    neighbours = find_neighbours(coords, grid)
    for neighbour in neighbours
        if grid[neighbour] == 0
            continue
        elseif grid[neighbour] == 9
            grid, flash_count = flash(neighbour, grid, flash_count)
        else
            grid[neighbour] += 1
        end
    end
    return grid, flash_count
end


function process_step(grid, flash_count)
    # initially increment every element by one
    grid = map(x->(x+1), grid)
    flasher_coords = findall(x->x>9, grid)
    for flasher in flasher_coords
        grid, flash_count = flash(flasher, grid, flash_count)
    end
    return grid, flash_count
end


function process_many_steps(grid, nstep)
    flash_count = 0
    for i in 1:nstep
        grid, flash_count = process_step(grid, flash_count)
    end
    return grid, flash_count
end


grid = read_input("input.txt")
grid, flash_count = process_many_steps(grid, 100)

println("answer is ", flash_count)
