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

def find_adjacency(shape):
    """Find adjacency for an array with shape, taken from my Day 9 solution."""
    adjacency = []
    for i in range(shape[0]*shape[1]):
        x, y = divmod(i, shape[1])
        adj = []
        if x > 0:
            # If row is not first, add above element index
            adj.append((i - shape[1]))
        if x < shape[0] - 1:
            # If row is not last, add below element index
            adj.append((i + shape[1]))
        if y > 0:
            # If column is not first, add left element index
            adj.append((i - 1))
        if y < shape[1] - 1:
            # If column is not last, add right element index
            adj.append((i + 1))
        adjacency.append(adj)
    return adjacency

def minimise_risk(risk_map, return_path=False):
    """Simple implementation of Dijkstra's algorithm to minimise risk in map.
    
    This could be optimized to not be an exhaustive search, but it runs in
    ~ 1 second which is good enough for now.

    Returns:
        int: Total risk for minimum path from top-left to bottom-right of
            risk_map.
        list of int: List of visited positions in risk_map.
    """
    adj = find_adjacency(risk_map.shape)
    risk = risk_map.ravel()

    heap = []  # To keep track of cumulative risk
    # visited = []  # To keep track of visited positions (e.g. for testing)
    cum_risk = [-1 for _ in risk]  # Cumulative risk is initially -1 everywhere

    def update(value, position):
        """Update heap, visited positions and cumulative risk"""
        heapq.heappush(heap, (value, position))  # Push risk value and position
        # visited.append(position)
        cum_risk[position] = value  # Update cumulative risk at position

    update(0, 0)  # Start at position 0 with a risk value of 0

    while heap:
        # Pop smallest item on the heap (corresponds to smallest cumulative risk)
        r, i = heapq.heappop(heap)
        for j in adj[i]:
            new_risk = r + risk[j]
            if cum_risk[j] > -1 and cum_risk[j] <= new_risk:
                # Ignore if previously visited with a lower cumulative risk
                continue
            update(new_risk, j)
    
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

    args = parser.parse_args()
    s = load_input(args.input_file)
    risk_map = expand_riskmap(riskmap_from_str(s), scale_factor=args.scale_factor)
    min_risk = minimise_risk(risk_map)
        
    print(f'Min risk = {min_risk}')
