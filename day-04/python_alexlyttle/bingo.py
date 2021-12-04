import numpy as np

def get_boards(lines, n=5):
    """Get n x n boards from lines of strings containing integers."""
    boards = []
    for l in lines:
        if l == '':
            continue  # Skip empty lines
        boards.append(l.split())
    num_boards = int(len(boards)//5)
    # Reshape so first axis contains each board
    return np.reshape(boards, (num_boards, n, n)).astype(int)  
    
def load_input(file_name):
    """Load input from file name, returns bingo draws and boards."""
    with open(file_name, 'r') as file:
        s = file.read()
    lines = s.splitlines()
    draws = list(map(int, lines[0].split(',')))
    return draws, get_boards(lines[1:])

def find_bingo(boards):
    """Determines whether a board has bingo."""
    rows = (boards.sum(axis=1) == 0).any(axis=1)
    cols = (boards.sum(axis=2) == 0).any(axis=1)
    return rows | cols  # Striked off numbers are zero

def calculate_score(draw, board):
    """Calculate score from """
    return draw * board.sum()

def score_board(draws, boards, pos=0):
    """Score board which finishes in position `pos`. Assumes the first board in
    in the array finishing at that position in the event of a tie."""
    num_boards = len(boards)
    rank = - pos if pos < 0 else num_boards - pos  # from 1 to num_boards
    
    if rank <= 0 or rank > num_boards:
        # Catch invalid position
        raise ValueError(f"Position '{pos}' out of range for {num_boards} boards")
    
    for draw in draws:
        boards[boards == draw] = 0  # Strike off draw from boards
        bingo = find_bingo(boards)
        if bingo.any():
            if len(bingo) == rank:
                break # Calculate score of board at given rank
            elif len(bingo) < rank:
                # This could happen if there was a tie somewhere
                raise ValueError(f"No board finished in position {pos}.")
            boards = boards[~bingo]  # Discard board(s) with bingo

    return calculate_score(draw, boards[bingo][0])  # Assume first board


if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Score bingo board in a given position'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-p', '--position', type=int, default=0,
                        help='position index')
    
    args = parser.parse_args()
    draws, boards = load_input(args.input_file)
    score = score_board(draws, boards, pos=args.position)
    print(f'Score = {score}')
