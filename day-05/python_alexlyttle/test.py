import unittest
from hydrothermal_vents import load_input, count_overlap

TESTINPUT = 'test_input.txt'


class TestHydroVents(unittest.TestCase):
    def test_count_overlap_1(self):
        vents = load_input(TESTINPUT)
        count = count_overlap(vents)
        self.assertEqual(count, 5)
    def test_count_overlap_2(self):
        vents = load_input(TESTINPUT)
        count = count_overlap(vents, diagonal=True)
        self.assertEqual(count, 12)


if __name__ == '__main__':
    unittest.main()
