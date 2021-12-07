import unittest
from lanternfish import populate

FISH = [3,4,3,1,2]


class TestLanternfish(unittest.TestCase):
    def test_populate_slow(self):
        total = populate(FISH, 18, method='slow')
        self.assertEqual(total, 26)

    def test_populate_80_days(self):
        total = populate(FISH, 80)
        self.assertEqual(total, 5934)

    def test_populate_256_days(self):
        total = populate(FISH, 256)
        self.assertEqual(total, 26984457539)

if __name__ == '__main__':
    unittest.main()
