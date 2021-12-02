
commands = readlines("input.txt")
x_position = 0
depth = 0

for command in commands
    local direction, distance = split(command)
    distance = parse(Int64, distance)
    if direction == "forward"
        global x_position += distance
    elseif direction == "down"
        global depth += distance
    elseif direction == "up"
        global depth -= distance
    else
        println("Unknown direction! :( ")
    end
end

println("x = ",x_position)
println("depth = ",depth)
println("x*depth = ",x_position*depth)
