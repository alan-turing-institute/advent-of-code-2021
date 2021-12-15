import numpy as np

def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    return s

def from_str(s):
    """Takes a string of instructions and returns coords of dots
    and fold instructions"""
    a, b = s.split('\n\n')
    coords = tuple(np.array(
        [[int(i) for i in line.split(',')] for line in a.splitlines()]
    ).T)
    folds = []
    for line in b.splitlines():
        axis, idx = line.split('=')
        folds.append((axis[-1], int(idx)))
    return coords, folds

def make_paper(coords):
    """Given coords of dots, returns paper where True corresponds to
    each dot"""
    x, y = coords
    paper = np.full((x.max()+1, y.max()+1), False)
    paper[coords] = True
    return paper

def fold_paper(paper, fold):
    """Folds paper according to axis and idx in fold"""
    axis, idx = fold
    first_half = slice(0, idx)
    second_half = slice(-1, idx, -1)
    if axis == 'y':
        first_half = (slice(None), first_half)
        second_half = (slice(None), second_half)
    elif axis != 'x':
        raise ValueError(f"Axis '{axis}' must be one of 'x' or 'y'")
    
    return paper[first_half] + paper[second_half]

def origami(coords, folds, num_folds=1):
    """Folds paper with dots at coords. num_folds=-1 corresponds
    to all fold instructions."""
    if num_folds == -1:
        num_folds = len(folds)
    paper = make_paper(coords)
    for i in range(num_folds):
        paper = fold_paper(paper, folds[i])
    return paper, np.count_nonzero(paper)

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Fold paper'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-n', '--num-folds', type=int, default=1,
                        help='number of folds')
    parser.add_argument('-p', '--print', action='store_true',
                        help='print final paper')

    args = parser.parse_args()
    s = load_input(args.input_file)
    paper, count = origami(*from_str(s), num_folds=args.num_folds)
    print(f'Number of dots = {count}')
    if args.print:
        p = np.full(paper.shape, '.')
        p[paper] = '#'
        p = '\n'.join([' '.join(col) for col in p.T])
        print(p)
