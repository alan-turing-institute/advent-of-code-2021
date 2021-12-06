"""AoC Day 6"""
from collections import Counter


def one(fish, days):
    shoal = Counter(fish)
    for day in range(days):
        new_shoal = {x: 0 for x in range(0, 9)}
        for key, value in shoal.items():
            if key > 0:
                new_shoal[key - 1] = shoal[key]

        new_shoal[6] += shoal[0]
        new_shoal[8] = shoal[0]
        shoal = new_shoal

    return sum(shoal.values())


if __name__ == "__main__":
    with open("input.txt", encoding="utf-8") as file:
        input_txt = file.read()
        input_list = [int(x) for x in input_txt.split(",")]

    answer = one(input_list, 80)
    print("one: ", answer)

    answer = one(input_list, 256)
    print("two: ", answer)
