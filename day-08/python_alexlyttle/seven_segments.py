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

  |         8 | 4 given 8 | 2 given 4 | 5 given 2
--------------|-----------|-----------|----------          
0 | abc.efg 6 | .bc..f. 3 | ..c.... 1 | ....... 0 [6 3 1 0]
1 | ..c..f. 2 | ------- - | ------- - | ------- - [2]
2 | a.cde.g 5 | ..cd... 2 | ------- - | ------- - [5 2]
3 | a.cd.fg 5 | ..cd.f. 3 | ..cd... 2 | ------- - [5 3 2]
4 | .bcd.f. 4 | ------- - | ------- - | ------- - [4]
5 | ab.d.fg 5 | .b.d.f. 3 | ...d... 1 | ------- - [5 3 1]
6 | ab.defg 6 | .b.d.f. 3 | ...d... 1 | ...d... 1 [6 3 1 1]
7 | a.c..f. 3 | ------- - | ------- - | ------- - [3]
8 | abcdefg 7 | ------- - | ------- - | ------- - [7]
9 | abcd.fg 6 | .bcd.f. 4 | ------- - | ------- - [6 4]

"""
def load_input(file_name):
    """Return scrambled digits and outputs from file."""
    with open(file_name, 'r') as file:
        s = file.read()
    lines = s.splitlines()
    digits, outputs = ([], [])
    for line in lines:
        d, o = line.split('|')
        digits.append([set(i) for i in d.split()])
        outputs.append([set(i) for i in o.split()])
    return digits, outputs

def decode_digits(digits):
    """Determines digits through comparison to known digits."""
    s = [None] * 10

    length = [[len(d)] for d in digits]
    
    def update(i, j):
        s[i] = digits.pop(length.index(j))
        length.remove(j)

    # The following could definitely be condensed 
    # Round 1 - num shared with 8
    for i, j in zip([1, 4, 7, 8], [[2], [4], [3], [7]]):
        update(i, j)
    
    length = [l + [len(s[4] & digits[i])] for i, l in enumerate(length)]
    
    # Round 2 - num shared with 8 and with 4
    for i, j in zip([2, 9], [[5, 2], [6, 4]]):
        update(i, j)
    
    # Round 3 - num shared with 8, 4 and 2
    length = [l + [len(s[2] & s[4] & digits[i])] for i, l in enumerate(length)]
    
    for i, j in zip([3, 5], [[5, 3, 2], [5, 3, 1]]):
        update(i, j)

    # Round 4 - num shared with 8, 4, 2 and 5
    length = [l + [len(s[5] & s[2] & s[4] & digits[i])] for i, l in enumerate(length)]
    
    for i, j in zip([0, 6], [[6, 3, 1, 0], [6, 3, 1, 1]]):
        update(i, j)

    return s

def decode_output(digits, outputs, full=False):
    """Decode output, either by returning frequency of unique digits
    or the full 4 digit number."""
    if full:
        value = ''
        for o in outputs:
            value += str(digits.index(o))
        return int(value)
    
    is_unique = [o in [digits[i] for i in [1, 4, 7, 8]] for o in outputs]
    return is_unique.count(True)

def decode_generator(digits, outputs, full=False):
    """Yield the desired output for each of digits and outputs"""
    for d, o in zip(digits, outputs):
        d = decode_digits(d)
        yield decode_output(d, o, full=full)
    
def sum_outputs(digits, outputs, full=False):
    """Sum the desired output for each of digits and outputs"""
    return sum(decode_generator(digits, outputs, full=full))

if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Decode seven segment digit display'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-f', '--full-output', action='store_true',
                        help='returns full output (part 2) rather than ' +
                             'frequency of unique digits [1, 4, 7, 8]')
    args = parser.parse_args()
    
    digits, outputs = load_input(args.input_file)
    count = sum_outputs(digits, outputs, full=args.full_output)
    print(f'Count = {count}')

# ------ CODE GRAVEYARD ------
# @np.vectorize
# def sort_strings(s):
#     return ''.join(sorted(s))

# def order_digits(digits):
#     digits = np.array(digits)
#     length = np.char.str_len(digits)
#     ordered_digits = np.empty_like(digits)
#     ordered_digits[:, 1] = digits[length == 2]
#     ordered_digits[:, 4] = digits[length == 4]
#     ordered_digits[:, 7] = digits[length == 3]
#     ordered_digits[:, 8] = digits[length == 7]
#     return ordered_digits

# def count_unique_digits(digits, output):
#     output = np.array(output)
#     ordered_digits = order_digits(digits)
#     sorted_digits = sort_strings(ordered_digits)
#     sorted_ouptut = sort_strings(output)
#     is_digit = np.isin(sorted_ouptut, sorted_digits)
#     return np.count_nonzero(is_digit)
