import unittest
from snailfish import Number, largest_magnitude

FILE_NAME = 'test_input.txt'


class TestSnailfish(unittest.TestCase):

    def test_1(self):
        numbers = Number.from_file(FILE_NAME)
        result = sum(numbers)
        self.assertEqual(result.magnitude(), 4140)

    def test_2(self):
        numbers = Number.from_file(FILE_NAME)
        self.assertEqual(largest_magnitude(numbers), 3993)


if __name__ == '__main__':
    unittest.main()
