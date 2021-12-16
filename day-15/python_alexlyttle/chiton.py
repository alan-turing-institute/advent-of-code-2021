import heapq
import numpy as np

def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    return s

def riskmap_from_str(s):
    return np.array(
        [list(map(int, list(line))) for line in s.splitlines()]
    )

def adjacency(i, shape):
    """Yield adjacency for position i in 2-D array with shape (N, M)."""
    x, y = divmod(i, shape[1])
    if x > 0:
        # If row is not first, add above element index
        yield i - shape[1]
    if x < shape[0] - 1:
        # If row is not last, add below element index
        yield i + shape[1]
    if y > 0:
        # If column is not first, add left element index
        yield i - 1
    if y < shape[1] - 1:
        # If column is not last, add right element index
        yield i + 1

def backpropagate(prev):
    """Backpropagate path given previous positions."""
    path = []
    k = len(prev) - 1  # Start at end
    while k is not None:
        path.append(k)
        k = prev[k]
    return path[::-1]  # To give list in order

def minimise_risk(risk_map, return_path=False):
    """Simple implementation of Dijkstra's algorithm to minimise risk in map.
    
    This could be optimized to not be an exhaustive search, but it runs in
    ~ 1 second which is good enough for now.

    Returns:
        int: Total risk for minimum path from top-left to bottom-right of
            risk_map.
        list of int: List of minimum path positions in risk_map.
    """
    risk = risk_map.ravel()

    heap = []  # To keep track of cumulative risk
    prev = [None] * len(risk)  # To keep track of previous positions
    cum_risk = [None] * len(risk)  # Cumulative risk is initially -1 everywhere

    def update(value, position, prev_position):
        """Update heap, visited positions and cumulative risk"""
        heapq.heappush(heap, (value, position))  # Push risk value and position
        prev[position] = prev_position
        cum_risk[position] = value  # Update cumulative risk at position

    update(0, 0, None)  # Start at position 0 with a risk value of 0

    while heap:
        # Pop smallest item on the heap (smallest cumulative risk)
        r, i = heapq.heappop(heap)
        for j in adjacency(i, risk_map.shape):
            new_risk = r + risk[j]
            if cum_risk[j] is None or new_risk < cum_risk[j]:
                # Only update if not visited or new risk is lower (better)
                update(new_risk, j, i)
    
    if return_path:
        return cum_risk[-1], backpropagate(prev)
    
    return cum_risk[-1]

def expand_riskmap(risk_map, scale_factor=1):
    """Expands risk map by a scale factor and applies rules to increase risk
    value along rows and columns according to AoC rules"""
    new_map = np.tile(risk_map, (scale_factor, scale_factor))
    
    # Not assuming the risk map has the same height as width
    rows = np.repeat(np.arange(scale_factor), risk_map.shape[0])
    cols = np.repeat(np.arange(scale_factor), risk_map.shape[1])

    # Add rows and cols to new map
    new_map += rows[:, None]
    new_map += cols
    new_map[new_map > 9] = new_map[new_map > 9] % 10 + 1  # Wrap back to 1
    return new_map
    
if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Minimise risk'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-s', '--scale-factor', type=int, default=1,
                        help='scale factor by which to expand the risk map')
    parser.add_argument('-p', '--print', action='store_true',
                        help='print minimum risk path')

    args = parser.parse_args()
    s = load_input(args.input_file)
    risk_map = expand_riskmap(riskmap_from_str(s), scale_factor=args.scale_factor)
    
    if args.print:
        min_risk, path = minimise_risk(risk_map, return_path=True)
        m = risk_map.astype(str)
        coords = np.divmod(path, risk_map.shape[1])
        # Make path bold
        m[coords] = np.char.add(np.char.add('\033[1m', m[coords]), '\033[0m')
        m = '\n'.join([''.join(col) for col in m.T])
        print(m)
        print('-'*risk_map.shape[1])
    else:
        min_risk = minimise_risk(risk_map)

    print(f'Min risk = {min_risk}')
