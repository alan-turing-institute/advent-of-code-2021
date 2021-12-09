import unittest
from smoke_basin import Heightmap

TESTMAP = '2199943210\n' + \
        '3987894921\n' + \
        '9856789892\n' + \
        '8767896789\n' + \
        '9899965678'


class TestSmokeBasin(unittest.TestCase):
    def test_low_points(self):
        hmap = Heightmap.from_string(TESTMAP)
        risk = hmap.get_risk()
        # print(TESTMAP[is_low])
        self.assertEqual(risk, 15)
    def test_basins(self):
        hmap = Heightmap.from_string(TESTMAP)
        size = hmap.fill_basins()
        # print(TESTMAP[is_low])
        self.assertEqual(size[-3:].prod(), 1134)


if __name__ == '__main__':
    unittest.main()
