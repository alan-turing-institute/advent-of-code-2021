using Unicode


global all_paths = []

function read_map(input_file)
    # return a dictionary with nodes as keys, and list of connected nodes as values
    map_dict = Dict("start"=>[],
                    "end"=>[])
    for line in readlines(input_file)
        first,second = split(line,"-")
        if (!).(in(first, keys(map_dict)))
            map_dict[first] = []
        end
        push!(map_dict[first], second)
        # opposite way around
        if (!).(in(second, keys(map_dict)))
            map_dict[second] = []
        end
        push!(map_dict[second], first)
    end
    # by hand don't allow to go back from 'end' to anywhere else
    map_dict["end"] = []
    return map_dict
end

function is_cave_small(cave_name)
    return all(x->Unicode.islowercase(x),cave_name)
end

function make_path_branches(current_path, map_dict)
    current_cave = current_path[length(current_path)]
    if current_cave == "end"
        push!(all_paths,current_path)
        return
    end
    for possibility in map_dict[current_cave]
        path = deepcopy(current_path)
        if (is_cave_small(possibility) == false) || (!).(in(possibility, path))
            push!(path, possibility)
            make_path_branches(path, map_dict)
        end
    end
    return
end

test_map = read_map("input.txt")

make_path_branches(["start"], test_map)
println("length of all paths is ",length(all_paths))
