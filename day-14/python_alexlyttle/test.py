import unittest
from polymer import polymerize, max_difference

TEST_INPUT = '''NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C'''


class TestPolymer(unittest.TestCase):
    def test_polymerize_1(self):
        diff = polymerize(TEST_INPUT)
        self.assertEqual(diff, 1588)
    def test_polymerize_2(self):
        diff = polymerize(TEST_INPUT, num_steps=40)
        self.assertEqual(diff, 2188189693529)

if __name__ == '__main__':
    unittest.main()
