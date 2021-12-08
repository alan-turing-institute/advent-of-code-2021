import unittest
from crabs import align

POS = [16,1,2,0,4,2,7,1,2,14]


class TestCrabsplosion(unittest.TestCase):
    def test_align_linear(self):
        self.assertEqual(align(POS, 'linear'), (2, 37))
    def test_align_triangular(self):
        self.assertEqual(align(POS, 'triangular'), (5, 168))

if __name__ == '__main__':
    unittest.main()
