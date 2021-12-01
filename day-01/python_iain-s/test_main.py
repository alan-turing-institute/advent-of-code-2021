from unittest import TestCase
from main import one, two


class TestOne(TestCase):
    def test_simple(self):
        self.assertEqual(7, one([199, 200, 208, 210, 200, 207, 240, 269, 260, 263]))


class TestTwo(TestCase):
    def test_simple(self):
        self.assertEqual(5, two([199, 200, 208, 210, 200, 207, 240, 269, 260, 263]))

