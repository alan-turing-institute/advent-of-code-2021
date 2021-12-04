import unittest
import numpy as np
from bingo import load_input, score_board

TESTINPUT = 'test_input.txt'


class TestBingo(unittest.TestCase):
    def test_win(self):
        draws, boards = load_input(TESTINPUT)
        score = score_board(draws, boards)
        self.assertEqual(score, 4512)
    def test_lose(self):
        draws, boards = load_input(TESTINPUT)
        score = score_board(draws, boards, pos=-1)
        self.assertEqual(score, 1924) 

if __name__ == '__main__':
    unittest.main()
