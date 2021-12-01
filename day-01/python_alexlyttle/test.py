import unittest
from count_increasing import count_increasing

TESTFILE = 'test_input.txt'


class TestCountIncreasing(unittest.TestCase):
    """Tests for count_increasing.py."""

    def test_count_1(self):
        """Tests count with default winodow width of 1."""
        self.assertEqual(count_increasing(TESTFILE), 7)

    def test_count_2(self):
        """Tests count with a window width of 3."""
        self.assertEqual(count_increasing(TESTFILE, 3), 5)


if __name__ == '__main__':
    unittest.main()
