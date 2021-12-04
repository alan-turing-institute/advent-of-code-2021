""" Racket too hard for weekends """

from typing import Dict, List, Optional

import numpy as np

# input space in input file, can be safely replaced for easier parsing
INDENT_SPACE = "    "
# square board
BOARD_SIZE = 5


class BingoBoard:
    number_map: Dict
    board: np.ndarray

    def __init__(self, numbers: List[List[int]]):
        self._check_size(numbers)
        # Dict for fast lookup when draw is made
        self.board = np.zeros((BOARD_SIZE, BOARD_SIZE), dtype=np.int32)
        self.number_map = dict()
        for i, row in enumerate(numbers):
            for j, number in enumerate(row):
                self.number_map[number] = (i, j)
                # negative so won't affect sum check of == BOARD_SIZE
                self.board[i, j] = -number

    @staticmethod
    def _check_size(numbers: List[List[int]]):
        assert len(numbers) == 5
        for row in numbers:
            assert len(row) == BOARD_SIZE

    def check_mark(self, draw: int):
        # check if number is on the board
        if draw in self.number_map:
            # mark as complete
            i, j = self.number_map[draw]
            self.board[i, j] = 1

            # check row
            if self.board[i, :].sum() == BOARD_SIZE:
                return True
            elif self.board[:, j].sum() == BOARD_SIZE:
                return True

        return False

    def sum_unmarked(self):
        unmarked_inds = np.where(self.board != 1.0)
        # unmarked items will hold negative number value
        return -self.board[unmarked_inds].sum()


def parse_number_line(line: str, separator: Optional[str] = None):
    """" parse string of numbers separated by given separator.
     default separator will be as str.split()"""
    return [int(x) for x in line.split(separator)]


def parse_input(input_string: str):
    # split on double line break, replace extra whitespace first and strip
    chunks = input_string.replace(INDENT_SPACE, "").strip().split("\n\n")
    # first chunk is drawn numbers
    drawn = chunks[0]
    drawn = parse_number_line(line=drawn, separator=",")
    # other chunks are bingo cards
    boards = chunks[1:]
    # split each board on \n and parse lines
    boards = [
        [parse_number_line(line=line) for line in board.split("\n")] for board in boards
    ]
    # convert to BingoBoard
    boards = [BingoBoard(board) for board in boards]
    return drawn, boards


def part_one(input_string: str):
    drawn_list, boards = parse_input(input_string)
    for draw in drawn_list:
        # note processes board iteratively, advantage to order
        for board in boards:
            if board.check_mark(draw=draw):
                return board.sum_unmarked() * draw
    raise Exception("No winner")


def part_two(input_string: str):
    drawn_list, boards = parse_input(input_string)
    complete_board_inds = set()
    minus_one_boards = len(boards) - 1
    for draw in drawn_list:
        # note processes board iteratively, advantage to order
        for i, board in enumerate(boards):
            # skip if already complete
            if i in complete_board_inds:
                continue
            if board.check_mark(draw=draw):
                if len(complete_board_inds) == minus_one_boards:
                    return board.sum_unmarked() * draw
                else:
                    complete_board_inds.add(i)
    raise Exception("Not enough winners.")


def test_solution():
    test_input = """7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
    
    22 13 17 11  0
     8  2 23  4 24
    21  9 14 16  7
     6 10  3 18  5
     1 12 20 15 19
    
     3 15  0  2 22
     9 18 13 17  5
    19  8  7 25 23
    20 11 10 24  4
    14 21 16 12  6
    
    14 21 17 24  4
    10 16 15  9 19
    18  8 23 26 20
    22 11 13  6  5
     2  0 12  3  7
    """
    score_one = part_one(test_input)
    assert score_one == 4512

    score_two = part_two(test_input)
    assert score_two == 1924


if __name__ == "__main__":
    input_fpath = "./input_4.txt"
    with open(input_fpath, "r") as f:
        in_str = f.read()
    score_one = part_one(in_str)
    score_two = part_two(in_str)
    print(f"answer one: {score_one}")
    print(f"answer two: {score_two}")
