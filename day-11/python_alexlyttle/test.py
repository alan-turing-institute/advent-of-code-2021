import unittest
from octopus import party_from_str, count_flashes, synchronise

INPUT = '5483143223\n' + \
        '2745854711\n' + \
        '5264556173\n' + \
        '6141336146\n' + \
        '6357385478\n' + \
        '4167524645\n' + \
        '2176841721\n' + \
        '6882881134\n' + \
        '4846848554\n' + \
        '5283751526'


class TestOctopus(unittest.TestCase):
    def test_count_flashed(self):
        party = party_from_str(INPUT)
        count = count_flashes(party)
        self.assertEqual(count, 1656)
    def test_sync(self):
        party = party_from_str(INPUT)
        step = synchronise(party)
        self.assertEqual(step, 195)

if __name__ == '__main__':
    unittest.main()
