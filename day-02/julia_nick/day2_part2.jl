
commands = readlines("input.txt")
x_position = 0
depth = 0
aim = 0

for command in commands
    local direction, dist = split(command)
    local distance = parse(Int64, dist)
    if direction == "forward"
        global x_position += distance
        global depth += distance * aim
    elseif direction == "down"
        global aim += distance
    elseif direction == "up"
        global aim -= distance
    else
        println("Unknown direction! :( ")
    end
end

println("x = ",x_position)
println("depth = ",depth)
println("x*depth = ",x_position*depth)
