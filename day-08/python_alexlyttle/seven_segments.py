"""
  0:      1:      2:      3:      4:
 aaaa    ....    aaaa    aaaa    ....
b    c  .    c  .    c  .    c  b    c
b    c  .    c  .    c  .    c  b    c
 ....    ....    dddd    dddd    dddd
e    f  .    f  e    .  .    f  .    f
e    f  .    f  e    .  .    f  .    f
 gggg    ....    gggg    gggg    ....

  5:      6:      7:      8:      9:
 aaaa    aaaa    aaaa    aaaa    aaaa
b    .  b    .  .    c  b    c  b    c
b    .  b    .  .    c  b    c  b    c
 dddd    dddd    ....    dddd    dddd
.    f  e    f  .    f  e    f  .    f
.    f  e    f  .    f  e    f  .    f
 gggg    gggg    ....    gggg    gggg

  |         8 | 4 given 8 | 2 given 4 | given 2
--------------|-----------|-----------|----------          
0 | abc.efg 6 | .bc..f. 3 | ..c.... 1 | .......   [6 3 1]
1 | ..c..f. 2 | ------- - | ------- - | ------- - [2]
2 | a.cde.g 5 | ..cd... 2 | ------- - | ------- - [5 2]
3 | a.cd.fg 5 | ..cd.f. 3 | ..cd... 2 | ------- - [5 3 2]
4 | .bcd.f. 4 | ------- - | ------- - | ------- - [4]
5 | ab.d.fg 5 | .b.d.f. 3 | ...d... 1 | ------- - [5 3 1]
6 | ab.defg 6 | .b.d.f. 3 | ...d... 1 | .......   [6 3 1]
7 | a.c..f. 3 | ------- - | ------- - | ------- - 
8 | abcdefg 7 | ------- - | ------- - | ------- - 
9 | abcd.fg 6 | .bcd.f. 4 | ------- - | ------- - 

"""
import numpy as np

def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    lines = s.splitlines()
    digits, output = ([], [])
    for line in lines:
        d, o = line.split('|')
        digits.append(d.split())
        output.append(o.split())
    return digits, output

@np.vectorize
def sort_strings(s):
    return ''.join(sorted(s))

def order_digits(digits):
    digits = np.array(digits)
    length = np.char.str_len(digits)
    ordered_digits = np.empty_like(digits)
    ordered_digits[:, 1] = digits[length == 2]
    ordered_digits[:, 4] = digits[length == 4]
    ordered_digits[:, 7] = digits[length == 3]
    ordered_digits[:, 8] = digits[length == 7]
    return ordered_digits

def count_unique_digits(digits, output):
    output = np.array(output)
    ordered_digits = order_digits(digits)
    sorted_digits = sort_strings(ordered_digits)
    sorted_ouptut = sort_strings(output)
    is_digit = np.isin(sorted_ouptut, sorted_digits)
    return np.count_nonzero(is_digit)

# def bits(digits, output):
#     b = np.empty(digits.shape + (7,), dtype=bool)
#     for i, sub in enumerate('abcdefg'):
#         b[:, :, i] = np.char.find(digits, sub) > -1
#     length = np.count_nonzero(b, axis=-1)
#     d = np.full_like(length, -1)
#     d[length == 2] = 1
#     d[length == 4] = 4
#     d[length == 3] = 7
#     d[length == 7] = 8
#     return b, d


if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Decode seven segment digit display'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')

    args = parser.parse_args()
    inputs = load_input(args.input_file)
    count = count_unique_digits(*inputs)
    print(f'Unique digits = {count}')
