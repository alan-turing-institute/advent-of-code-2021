import numpy as np
        
def load_input(file_name):
    """Returns the vents from input file. Vents have shape 
    (num_vents, 2, 2) where axis 1 is the x-y coordinate and
    axis 2 is the start or end point of the vent.
    """
    with open(file_name, 'r') as file:
        s = file.read()
    lines = s.splitlines()
    num_vents = len(lines)
    # Vents have shape (num_vents, num_axes, num_points)
    # num_axes is 2 (x, y) and num_points is 2 (start, end) 
    vents = np.zeros((num_vents, 2, 2), dtype=int)
    for i, line in enumerate(lines):
        l = line.split()
        vents[i, :, 0] = l[0].split(',')
        vents[i, :, 1] = l[2].split(',')
    return vents

def drop_diagonals(vents):
    """Drop diagonal vents."""
    mask = (np.diff(vents) == 0).any(axis=(1, 2))
    return vents[mask]

def fill_map(vents, diagonal=False):
    """Fill a map with the vents. Diagonal vents ignored by default."""
    if not diagonal:
        vents = drop_diagonals(vents)  # remove diagonals
    shape = vents.max(axis=(0, 2)) + 1  # max x and y
    m = np.zeros(shape)

    # Steps are just 1 if difference is positive and zero if negative
    steps = np.squeeze(np.diff(vents))
    steps[steps >= 0] = 1
    steps[steps < 0] = -1
    
    for vent, step in zip(vents, steps):
        # i and j are each coord on m occupied by vent
        # e.g. vent[1, 0] is the y coord start position
        # and step[1] is the y coord step
        i, j = np.ogrid[vent[0, 0]:vent[0, 1]+step[0]:step[0],
                        vent[1, 0]:vent[1, 1]+step[1]:step[1]]
        m[i, j.T] += 1
    return m

def count_overlap(vents, min_overlap=2, diagonal=False):
    """Count overlapping vents."""
    m = fill_map(vents, diagonal=diagonal)
    return np.count_nonzero(m >= min_overlap)

if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Determine number of vent crossovers of at least 2.'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-d', '--diagonal', action='store_true',
                        help='include diagonal vents')
    
    args = parser.parse_args()
    vents = load_input(args.input_file)
    count = count_overlap(vents, diagonal=args.diagonal)
    print(f'Overlapping vents = {count}')
