import numpy as np

def load_input(file_name):
    with open(file_name, 'r') as file:
        return file.read()

def party_from_str(s):
    lines = s.splitlines()
    return np.array([[int(i) for i in line] for line in lines])

def update(party):
    """Update the party of octopuses. 
    There is probably a faster way."""
    party += 1
    while np.any(party > 9):
        i, j = np.where(party > 9)
        
        n = i > 0
        e = j < party.shape[1] - 1
        s = i < party.shape[0] - 1
        w = j > 0
        ne = n & e
        se = s & e
        nw = n & w
        sw = s & w
        
        # north, northeast, east, southeast, south, southwest, west, northwest
        i_adj = [
            i[n] - 1, i[ne] - 1, i[e], i[se] + 1,
            i[s] + 1, i[sw] + 1, i[w], i[nw] - 1,
        ]
        j_adj = [
            j[n], j[ne] + 1, j[e] + 1, j[se] + 1,
            j[s], j[sw] - 1, j[w] - 1, j[nw] - 1,
        ]

        party[(i, j)] = 0
        # This could be improved
        for d in range(8):
            is_adj = np.full(party.shape, False)
            is_adj[(i_adj[d], j_adj[d])] = True
            party[(party > 0) & is_adj] += 1
    return party

def count_flashes(party, num_steps=100):
    count = 0
    for step in range(num_steps):
        party = update(party)
        count += np.count_nonzero(party == 0)
    return count

def synchronise(party):
    step = 0
    while np.any(party > 0):
        party = update(party)
        step += 1
    return step

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Count octopus flashes'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-s', '--sync', action='store_true')

    args = parser.parse_args()
    s = load_input(args.input_file)
    party = party_from_str(s)
    
    if args.sync:
        step = synchronise(party)
        print(f'Step = {step}')
    else:
        count = count_flashes(party)
        print(f'Count = {count}')
    
