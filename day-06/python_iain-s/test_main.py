import unittest
from main import one


instructions = [3, 4, 3, 1, 2]


class TestOne(unittest.TestCase):
    def test_simple(self):
        self.assertEqual(26, one(instructions, 18))
        self.assertEqual(5934, one(instructions, 80))
        self.assertEqual(26984457539, one(instructions, 256))


if __name__ == "__main__":
    unittest.main()
