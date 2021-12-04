import numpy as np

def load_input(file_name):
    """Loads input from file and converts to array of 1s and 0s."""
    data = np.loadtxt(file_name, dtype=str)
    data = np.array(list(map(list, data))).astype(int)
    return data

def occurrence(data, less=False):
    """Occurrence of more ones than zeros in axis 0 of data."""
    num_ones = data.sum(axis=0)
    num_zeros = data.shape[0] - num_ones
    if less:
        return num_zeros > num_ones
    return num_ones >= num_zeros

def binary_array_to_int(x, sep=''):
    """Turn 1D array `x` of 0s and 1s into integer."""
    return int(sep.join(x.astype(str)), 2)

def power(data):
    """Determine power rating."""
    more_ones = occurrence(data)
    gamma = binary_array_to_int(more_ones.astype(int))
    epsilon = binary_array_to_int((~more_ones).astype(int))
    return gamma * epsilon
    
def creme_de_la_creme(data, less=False):
    """Finds the rating for the best of the best in data according to common_func."""
    i = 0
    while data.shape[0] > 1:
        d = data[:, i]
        more_ones = occurrence(d, less=less)  # Whether or not there are more ones
        data = data[d==more_ones]
        i += 1
    return binary_array_to_int(data[0])

def life_support(data):
    """Determine life support rating."""
    oxygen = creme_de_la_creme(data)
    carbon = creme_de_la_creme(data, less=True)
    return oxygen * carbon
    
if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Diagnose input'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    
    args = parser.parse_args()
    data = load_input(args.input_file)
    p = power(data)
    l = life_support(data)
    print(f'Power = {p}')
    print(f'Life support = {l}')
