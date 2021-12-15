import unittest
from origami import from_str, origami

TEST_INPUT = '''6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5'''


class TestOrigami(unittest.TestCase):
    def test_origami_1(self):
        coords, folds = from_str(TEST_INPUT)
        paper, count = origami(coords, folds)
        self.assertEqual(count, 17)


if __name__ == '__main__':
    unittest.main()
