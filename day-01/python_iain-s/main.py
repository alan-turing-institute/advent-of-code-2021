"""AoC Day 1"""


def one(measurements):
    staggered = measurements[1:]
    return sum(map(lambda x, y: 1 if y > x else 0, measurements, staggered))


def two(measurements):
    staggered_one = measurements[1:]
    staggered_two = measurements[2:]

    def add(*args):
        """There must be a builtin to do this but I don't know what it is!"""
        return sum(args)

    windowed_measurements = list(map(add, measurements, staggered_one, staggered_two))
    return one(windowed_measurements)


if __name__ == "__main__":
    with open("input.txt", encoding="utf-8") as file:
        input_list = [int(x) for x in file.readlines()]

    answer = one(input_list)
    print("one: ", answer)

    answer = two(input_list)
    print("two: ", answer)
