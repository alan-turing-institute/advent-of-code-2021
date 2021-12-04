import numpy as np

def total_displacement(file_name, use_aim=False):
    """Calculate total displacement given directions in a file."""
    data = np.loadtxt(file_name, dtype=str)
    direction = data[:, 0]
    magnitude = data[:, 1].astype(int)
    magnitude[direction == 'up'] *= -1  # Vertical unit points down

    is_forward = direction == 'forward'
    horizontal = magnitude[is_forward]
    
    # Vertical movement is all which are not forward
    vertical = np.zeros_like(magnitude)
    vertical[~is_forward] = magnitude[~is_forward]

    if use_aim:
        aim = np.cumsum(vertical)
        vertical = aim[is_forward] * horizontal
    
    return horizontal.sum(), vertical.sum()

if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Calculate total displacement of input file'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-a', '--aim', action='store_true',
                        help='use aim mode')
    args = parser.parse_args()

    h, v = total_displacement(args.input_file, args.aim) 
    print(f'Horizontal = {h} units forward')
    print(f'Vertical   = {v} units down')
    print(f'Product    = {h*v} units squared')
