import unittest
from seven_segments import load_input, count_unique_digits

INPUTFILE = 'test_input.txt'


class TestSevenSegments(unittest.TestCase):
    def test_unique_digits(self):
        inputs = load_input(INPUTFILE)
        count = count_unique_digits(*inputs)
        self.assertEqual(count, 26)

if __name__ == '__main__':
    unittest.main()
