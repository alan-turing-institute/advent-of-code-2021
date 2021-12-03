
function get_position_aim(direction, distance, verticle_distance, horizontal_distance, aim)
  if direction == "forward"
    horizontal_distance += distance
    verticle_distance += distance * aim
  elseif direction == "up"
    aim -= distance
  else
    aim += distance
  end
  return verticle_distance, horizontal_distance, aim
end

verticle_distance = 0
horizontal_distance = 0
aim = 0

instructions = readlines("input.txt", keep=true)
function final_position_aim(instructions, get_position_aim, verticle_distance, horizontal_distance, aim)
  for instruction in instructions
    direction, distance = split(instruction)
    distance = parse(Int64, distance)
    verticle_distance, horizontal_distance, aim = get_position_aim(direction, distance, verticle_distance, horizontal_distance, aim)
  end
  return verticle_distance*horizontal_distance
end


print("The final position inclusive of aim is: ", final_position_aim(instructions, get_position_aim, verticle_distance, horizontal_distance, aim))
