import numpy as np

def count_increasing(file_name, window_width=1):
    """Count increasing consecutive values in a file over a given window."""
    data = np.loadtxt(file_name, dtype=int)
    moving_sum = np.convolve(data, np.ones(window_width), 'valid')
    return np.sum(np.diff(moving_sum) > 0)

if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Count increasing consecutive integers'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-w', '--window-width', type=int, dest='window_width',
                        default=1, help='window width for moving sum')
    args = parser.parse_args()

    print(count_increasing(args.input_file, args.window_width))
