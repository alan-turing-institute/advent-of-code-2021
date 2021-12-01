import numpy as np

input = np.loadtxt("input.txt", dtype=int)


def day_1_part_1(x):
    return np.sum((np.diff(x) > 0))


def day_1_part_2(x):
    windowed = np.lib.stride_tricks.sliding_window_view(input, 3).sum(axis=1)
    return day_1_part_1(windowed)


if __name__ == "__main__":

    print(f"Day 1 Part 1 = { day_1_part_1(input)}")
    print(f"Day 1 Part 2 = { day_1_part_2(input)}")
