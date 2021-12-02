"""AoC Day 2"""


def run(env):
    """AoC. Probably the only time it's OK to use eval in Python."""

    for instruction in env["instructions"]:
        function, arg = instruction.split(" ")
        env["position"] = eval(
            # e.g. forward(5, (0 + 2j, 1))
            function + "(" + arg + "," + repr(env["position"]) + ")",
            dict(),
            env,
        )

    return env["position"]


def one(instructions):
    position = 0 + 0j  # x and y
    forward = lambda amount, current: current + amount
    down = lambda amount, current: current + 1j * amount
    up = lambda amount, current: current - 1j * amount

    position = run(locals())

    return position.real * position.imag


def two(instructions):
    position = 0 + 0j, 0  # x, y and aim
    forward = lambda amount, current: (
        current[0] + amount + (amount * 1j * current[1]),
        current[1],
    )
    down = lambda amount, current: (current[0], current[1] + amount)
    up = lambda amount, current: (current[0], current[1] - amount)

    position = run(locals())

    return position[0].real * position[0].imag


if __name__ == "__main__":
    with open("input.txt", encoding="utf-8") as file:
        input_list = file.read().splitlines()

    answer = one(input_list)
    print("one: ", answer)

    answer = two(input_list)
    print("two: ", answer)
