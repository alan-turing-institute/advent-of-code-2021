import unittest
from spelunking import graph_from_str, count_paths

SMALL_CAVE = 'start-A\n' + \
             'start-b\n' + \
             'A-c\n' + \
             'A-b\n' + \
             'b-d\n' + \
             'A-end\n' + \
             'b-end'

LARGE_CAVE = 'fs-end\n' + \
             'he-DX\n' + \
             'fs-he\n' + \
             'start-DX\n' + \
             'pj-DX\n' + \
             'end-zg\n' + \
             'zg-sl\n' + \
             'zg-pj\n' + \
             'pj-he\n' + \
             'RW-he\n' + \
             'fs-DX\n' + \
             'pj-RW\n' + \
             'zg-RW\n' + \
             'start-pj\n' + \
             'he-WI\n' + \
             'zg-he\n' + \
             'pj-fs\n' + \
             'start-RW'


class TestSpelunking(unittest.TestCase):
    def test_small_cave_1(self):
        graph = graph_from_str(SMALL_CAVE)
        self.assertEqual(count_paths(graph), 10)
    def test_large_cave(self):
        graph = graph_from_str(LARGE_CAVE)
        self.assertEqual(count_paths(graph), 226)
    def test_small_cave_2(self):
        graph = graph_from_str(SMALL_CAVE)
        self.assertEqual(count_paths(graph, max_visits=2), 36)
    
if __name__ == '__main__':
    unittest.main()
