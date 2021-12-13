
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
    output_coords = []
    for coord in input_coords
        if fold_axis == "y" #fold up
            if coord[2] < fold_value
                push!(output_coords, coord)
            else
                folded_coord = [coord[1], coord[2*fold_value - coord[2]]]
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


input_dots, folds = read_dots_folds("input.txt")

output_dots = fold(input_dots, folds[1][1], folds[1][2])

println("number of output dots ", length(output_dots))
