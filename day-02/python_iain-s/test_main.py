import unittest
from main import one, two


instructions = [
    "forward 5",
    "down 5",
    "forward 8",
    "up 3",
    "down 8",
    "forward 2",
]


class TestOne(unittest.TestCase):
    def test_simple(self):
        self.assertEqual(150, one(instructions))


class TestTwo(unittest.TestCase):
    def test_simple(self):
        self.assertEqual(900, two(instructions))


if __name__ == "__main__":
    unittest.main()
