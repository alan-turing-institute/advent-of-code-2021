import numpy as np

TEST_INPUT = '''NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C'''

def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    return s

def from_str(s):
    """Returns initial chain of pairs and pair insertion rules"""
    lines = s.splitlines()
    chain = [(i, j) for i, j in zip(lines[0][:-1], lines[0][1:])]
    rules = dict([line.split(' -> ') for line in lines[2:]])
    rules = {tuple(k): v for k, v in rules.items()}
    return chain, rules

def count_pairs(count, rules):
    """Counts the pairs after one round of polymer growth"""
    new_count = dict.fromkeys(rules.keys(), 0)
    for pair, value in count.items():
        if value == 0:
            continue  # No pairs
        new = rules[pair]  # Letter to be inserted
        new_count[(pair[0], new)] += value
        new_count[(new, pair[1])] += value
    return new_count

def max_difference(count, init_chain):
    """From the count and initial chain, returns the max difference
    between the frequency of each letter in count."""
    keys = ()
    for key in count.keys():
        keys += key
    freq = dict.fromkeys(set(keys), 0)
    for pair, value in count.items():
        freq[pair[0]] += value
    freq[init_chain[-1][-1]] += 1  # Add final letter (never changes)
    return max(freq.values()) - min(freq.values())

def polymerize(s, num_steps=10):
    """Grow polymer for num_steps."""
    chain, rules = from_str(s)
    count = dict.fromkeys(rules.keys(), 0)
    for pair in chain:
        count[pair] += 1

    for i in range(num_steps):
        count = count_pairs(count, rules)

    return max_difference(count, chain)

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Grow polymer chain'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-n', '--num-steps', type=int, default=10,
                        help='number of steps')

    args = parser.parse_args()
    s = load_input(args.input_file)
    diff = polymerize(s, num_steps=args.num_steps)
    print(f'Max difference = {diff}')
