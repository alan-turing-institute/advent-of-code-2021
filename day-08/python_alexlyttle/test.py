import unittest
from seven_segments import load_input, sum_outputs

INPUTFILE = 'test_input.txt'


class TestSevenSegments(unittest.TestCase):
    def test_unique_digits(self):
        inputs = load_input(INPUTFILE)
        count = sum_outputs(*inputs)
        self.assertEqual(count, 26)
    def test_total_output(self):
        inputs = load_input(INPUTFILE)
        count = sum_outputs(*inputs, full=True)
        self.assertEqual(count, 61229)
        
if __name__ == '__main__':
    unittest.main()
