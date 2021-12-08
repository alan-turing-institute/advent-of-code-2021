import numpy as np

def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    return list(map(int, s.split(',')))

@np.vectorize
def triangular(distance):
    """Sum of n from 1 to distance"""
    # This way is still a little slow, must be a way to do this
    # once and apply to all points on grid rather than repeat
    # this calculation (e.g. for same distances)
    return np.arange(1, distance + 1).sum()
    
def align(position, burn_rate='linear'):
    """Returns the best target and cost of moving crabs to the target.
    Burn rate is either 'linear' or 'triangular'.
    """
    if burn_rate not in ['linear', 'triangular']:
        raise ValueError(f"Burn rate '{burn_rate}' not available.")

    position = np.array(position)
    target = np.arange(position.max())
    cost = np.abs(position - target[:, None])  # cost is prop to distance
    if burn_rate == 'triangular':
        cost = triangular(cost)  # cost is triangular number of distance
    total_cost = cost.sum(axis=1)
    return total_cost.argmin(), total_cost.min()

if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Determine minimum fuel cost to align crabs'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-b', '--burn-rate', type=str,
                        choices=['linear', 'triangular'],
                        default='linear', help='burn rate')


    args = parser.parse_args()
    pos = load_input(args.input_file)
    target, cost = align(pos, burn_rate=args.burn_rate)
    print(f'Minimum cost = {cost}')
