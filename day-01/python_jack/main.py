import pandas as pd


def part_1(data):
    return (data.diff() > 0).sum()


def part_2(data):
    return part_1(data.rolling(3).sum())


if __name__ == "__main__":
    data = pd.read_csv("input.txt", header=None)[0]
    print("Part 1:", part_1(data))
    print("Part 2:", part_2(data))
