import unittest
from io import StringIO

from navigate import total_displacement

TESTINPUT = (
    'forward 5\n' +
    'down 5\n' +
    'forward 8\n' +
    'up 3\n' +
    'down 8\n' +
    'forward 2'
)


class TestNavigate(unittest.TestCase):

    def test_total_displacement_1(self):
        input_file = StringIO(TESTINPUT)
        self.assertEqual(total_displacement(input_file), (15, 10))

    def test_total_displacement_2(self):
        input_file = StringIO(TESTINPUT)
        self.assertEqual(total_displacement(input_file, use_aim=True),
                         (15, 60))


if __name__ == '__main__':
    unittest.main()
