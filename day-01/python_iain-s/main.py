"""AoC Day 1"""


def one(measurements):
    count = 0
    previous = measurements[0]
    for measurement in measurements[1:]:
        if measurement > previous:
            count += 1
        previous = measurement

    return count


def two(measurements):
    windowed_measurements = []
    offset = 0
    while True:
        subset = measurements[offset:offset+3]
        if len(subset) < 3:
            break
        else:
            windowed_measurements.append(sum(subset))
            offset += 1

    return one(windowed_measurements)


if __name__ == "__main__":
    with open("input.txt", encoding="utf-8") as file:
        input_list = [int(x) for x in file.readlines()]

    answer = one(input_list)
    print("one: ", answer)

    answer = two(input_list)
    print("two: ", answer)
