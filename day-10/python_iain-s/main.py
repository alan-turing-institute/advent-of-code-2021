"""AoC Day 10"""


pairs = (
    "{",
    "}",
    "[",
    "]",
    "<",
    ">",
    "(",
    ")",
)
openings = pairs[0::2]
closings = pairs[1::2]


def compose(*functions):
    def inner(arg):
        for f in reversed(functions):
            arg = f(arg)
        return arg
    return inner


def find_corrupted(line):
    """Return the first bad char in line or None if the line isn't corrupted.

    By "bad", we mean a closing bracket without a matching opening bracket."""
    stack = []
    for char in line:
        if char in openings:
            stack.append(char)
        elif char in closings:
            closing_index = closings.index(char)
            if stack[-1] == openings[closing_index]:
                stack.pop()
            else:
                return char
        else:
            raise RuntimeError(char + " not recognised")


def one(lines):
    """Score the corrupted lines."""
    points = {
        ")": 3,
        "]": 57,
        "}": 1197,
        ">": 25137,
    }
    lookup = lambda x: points.get(x, 0)

    total = sum(map(compose(lookup, find_corrupted), lines))
    return total


def find_closings(line):
    stack = []
    for char in line:
        if char in openings:
            stack.append(char)
        elif char in closings:
            closing_index = closings.index(char)
            if stack[-1] == openings[closing_index]:
                stack.pop()
        else:
            raise RuntimeError(char + " not recognised")
    result = ""
    for x in stack[::-1]:
        # If, e.g., "{" is the zeroth element in openings then we want "}",
        # which will be the zeroth element in closings
        result += closings[openings.index(x)]
    return result


def get_score(string):
    points = {
        ")": 1,
        "]": 2,
        "}": 3,
        ">": 4,
    }
    total = 0
    for x in string:
        total *= 5
        total += points[x]
    return total


def two(lines):
    """Score the incomplete lines."""
    scores = sorted(map(compose(get_score, find_closings),
                    filter(lambda line: find_corrupted(line) is None, lines)))
    return scores[len(scores)//2]


if __name__ == "__main__":
    with open("input.txt", encoding="utf-8") as file:
        input_list = file.read().splitlines()

    answer = one(input_list)
    print("one: ", answer)

    answer = two(input_list)
    print("two: ", answer)
