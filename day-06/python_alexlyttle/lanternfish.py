"""Resisting the urge to just fit a power law to this one, I am an astronomer
after all.
"""
def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    return list(map(int, s.split(',')))

def update_fish(fish, period=7, grace=2):
    fish += fish.count(0) * [period + grace]
    fish = [(f - 1) if f > 0 else period - 1 for f in fish]
    return fish

def update_count(count, period=7):
    parent = count[0]
    count[:-1] = count[1:]
    count[period - 1] += parent
    count[-1] = parent
    return count
    
def populate(fish, num_days, period=7, grace=2, method='fast'):
    if method == 'slow':
        # Part 1
        for _ in range(num_days):
            fish = update_fish(fish, period=period, grace=grace)
        return len(fish)
    elif method == 'fast':
        # Part 2
        count = [fish.count(i) for i in range(period + grace)]
        for _ in range(num_days):
            count = update_count(count, period=period)
        return sum(count)
    raise NotImplementedError(f"Method '{method}' not implemented.")

if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Determine population of fish after N days.'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('days', type=int, metavar='N', help='number of days')

    parser.add_argument('-p', '--period', type=int,
                        default=7, help='period of reproduction (days)')
    parser.add_argument('-g', '--grace', type=int,
                    default=2, help='grace period before reproduction cycle (days)')
    parser.add_argument('-m', '--method', type=str, choices=['fast', 'slow'],
                        default='fast', help='method to find population')

    args = parser.parse_args()
    fish = load_input(args.input_file)
    total_fish = populate(fish, args.days, period=args.period, grace=args.grace,
                          method=args.method)
    print(f'Total fish = {total_fish}')
