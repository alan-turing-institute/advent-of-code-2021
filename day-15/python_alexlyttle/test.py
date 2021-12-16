import unittest
from chiton import riskmap_from_str, expand_riskmap, minimise_risk

TEST_INPUT = '''1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581'''


class TestChiton(unittest.TestCase):
    def test_min_risk_1(self):
        risk_map = expand_riskmap(riskmap_from_str(TEST_INPUT))
        min_risk = minimise_risk(risk_map)
        self.assertEqual(min_risk, 40)
    def test_min_risk_2(self):
        risk_map = expand_riskmap(riskmap_from_str(TEST_INPUT), 5)
        min_risk = minimise_risk(risk_map)
        self.assertEqual(min_risk, 315)

if __name__ == '__main__':
    unittest.main()
