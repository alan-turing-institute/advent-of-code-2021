CHUNKS = {
    '(': ')',
    '[': ']',
    '{': '}',
    '<': '>',
}

CORR_SCORE = {
    ')': 3,
    ']': 57,
    '}': 1197,
    '>': 25137,
}

COMP_SCORE = {
    ')': 1,
    ']': 2,
    '}': 3,
    '>': 4,
}

def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    return s.splitlines()
   
def score_corruption(line):
    """Loops through line and returns unclosed opening chunks and score if
    line is corrupted (otherwise None)."""
    opening = []  # Opening chunks
    for c in line:
        if c in CHUNKS.keys():
            opening.append(c)  # Track opening chunks
        else:
            # opening.pop() done regardless of this being true
            if c != CHUNKS[opening.pop()]:
                return opening, CORR_SCORE[c]  # Break out of loop
    return opening, None  # Score of None returned

def score_syntax(lines):
    """Score syntax corruption and completion."""
    corruption_score = 0
    completion_score = []
    for line in lines:
        opening, score = score_corruption(line)
        
        if score is not None:
            corruption_score += score
            continue

        cs = 0
        for o in opening[::-1]:
            # Reverse order of opening
            cs = 5 * cs + COMP_SCORE[CHUNKS[o]]
        completion_score.append(cs)

    median = len(completion_score)//2  # Assume odd number of lines
    return corruption_score, sorted(completion_score)[median]

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Score syntax in file'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')

    args = parser.parse_args()
    lines = load_input(args.input_file)
    corr_score, comp_score = score_syntax(lines)
    print(f'Corruption score = {corr_score}')
    print(f'Completion score = {comp_score}')
