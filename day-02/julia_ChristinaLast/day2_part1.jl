module GetPositionInstructions

  function get_position(direction, distance, verticle_distance, horizontal_distance)
    if direction == "forward"
      horizontal_distance += distance
    elseif direction == "up"
      verticle_distance -= distance
    else
      verticle_distance += distance
    end
    return verticle_distance, horizontal_distance
  end


  verticle_distance = 0
  horizontal_distance = 0

  instructions = readlines("input.txt", keep=true)
  function final_position(instructions, get_position, verticle_distance, horizontal_distance)
    for instruction in instructions
      direction, distance = split(instruction)
      distance = parse(Int64, distance)
      verticle_distance, horizontal_distance = get_position(direction, distance, verticle_distance, horizontal_distance)
    end
    return verticle_distance*horizontal_distance
  end

  print("The final position of the ship is: ", final_position(instructions, get_position, verticle_distance, horizontal_distance))
end
export final_position, get_position
