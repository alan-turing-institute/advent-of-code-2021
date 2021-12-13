
function read_dots_folds(input_file)
    coords = []
    folds = []
    for line in readlines(input_file)
        if ',' in line
            x,y = map(x->parse(Int,x), split(line, ','))
            push!(coords, [x,y])
        elseif '=' in line
            axis, value = split(split(line)[3], '=')
            value = parse(Int, value)
            push!(folds, [axis, value])
        end
    end
    return coords, folds
end


function fold(input_coords, fold_axis, fold_value)
    println("folding ",fold_axis, " ", fold_value)
    output_coords = []
    for coord in input_coords
        if fold_axis == "y" #fold up
            if coord[2] < fold_value
                push!(output_coords, coord)
            else
                folded_coord = [coord[1], 2*fold_value - coord[2]]
                push!(output_coords, folded_coord)
            end
        else # fold left
            if coord[1] < fold_value
                push!(output_coords, coord)
            else
                folded_coord = [2*fold_value - coord[1], coord[2]]
                push!(output_coords, folded_coord)
            end
        end
    end
    # deduplicate by putting into a set
    return Set(output_coords)
end

function test_folds()
    test_coords = [[3,4],[11,18]]
    @assert fold(test_coords, "x", 10) == Set([[3,4],[9,18]])
    @assert fold(test_coords, "y", 10) == Set([[3,4],[11,2]])
    new_dots = fold(test_coords, "y", 10)
    @assert fold(new_dots, "x", 6) == Set([[3,4],[1,2]])
end

test_folds()


function do_all_folds(coords, folds)
    for f in folds
        coords = fold(coords, f[1], f[2])
        println("number of coords ", length(coords))
    end
    return coords
end


function draw_grid(coords)
    xmax = maximum(x->x[1], coords)+1
    ymax = maximum(x->x[2], coords)+1
    grid = ones(String, ymax, xmax)

    # now draw on the coords
    for coord in coords
        grid[coord[2]+1,coord[1]+1] = "#"
    end
    return grid

end

#
input_dots, folds = read_dots_folds("input.txt")
#
output_dots = do_all_folds(input_dots, folds)
#
println("number of output dots ", length(output_dots))
#
draw_grid(output_dots)
