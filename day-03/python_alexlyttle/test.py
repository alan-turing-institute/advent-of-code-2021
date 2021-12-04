import unittest
from io import StringIO

from diagnose import load_input, power, life_support

TESTINPUT = StringIO(
    '00100\n' +
    '11110\n' +
    '10110\n' +
    '10111\n' +
    '10101\n' +
    '01111\n' +
    '00111\n' +
    '11100\n' +
    '10000\n' +
    '11001\n' +
    '00010\n' +
    '01010\n'
)
DATA = load_input(TESTINPUT)

class TestDiagnose(unittest.TestCase):
    def test_diagnose_power(self):
        self.assertEqual(power(DATA), 198)
    def test_diagnose_oxygen(self):
        self.assertEqual(life_support(DATA), 230)

if __name__ == '__main__':
    unittest.main()
