import unittest
from snailfish import NumberList

FILE_NAME = 'test_input.txt'


class TestSnailfish(unittest.TestCase):

    def test_1(self):
        numbers = NumberList.from_file(FILE_NAME)
        result = sum(numbers)
        self.assertEqual(result.magnitude(), 4140)

    def test_2(self):
        numbers = NumberList.from_file(FILE_NAME)
        self.assertEqual(numbers.largest_magnitude(), 3993)


if __name__ == '__main__':
    unittest.main()
