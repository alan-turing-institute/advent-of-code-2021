using Unicode
# urgh, doesn't seem good to use this global, but it works...
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

function can_i_visit_cave(cave, path)
    if (is_cave_small(cave) == false)
        return true
    elseif cave == "start"
        return false
    elseif (!).(in(cave, path))
        return true
    else
        # see if any other small caves have been visited twice
        for other_cave in path
            if all(x->Unicode.isuppercase(x),other_cave)
                continue
            end
            if count(x->x==other_cave, path) == 2
                return false
            end
        end
    end
    return true
end

function test_can_i_visit_cave()
    @assert can_i_visit_cave("A",["start","A","b"]) == true
    @assert can_i_visit_cave("b",["start","A","b"]) == true
    @assert can_i_visit_cave("start",["start","A","b"]) == false
    @assert can_i_visit_cave("c",["start","A","b"]) == true
    @assert can_i_visit_cave("c",["start","A","b","b"]) == true
    @assert can_i_visit_cave("c",["start","A","b","b","c"]) == false
end

test_can_i_visit_cave()

function make_path_branches(current_path, map_dict)
    current_cave = current_path[length(current_path)]
    if current_cave == "end"
        push!(all_paths,current_path)
        return
    end
    for possibility in map_dict[current_cave]
        path = deepcopy(current_path)
        if can_i_visit_cave(possibility, path)
            push!(path, possibility)
            make_path_branches(path, map_dict)
        end
    end
    return
end

test_map = read_map("input.txt")

make_path_branches(["start"], test_map)
println("length of all paths is ",length(all_paths))
