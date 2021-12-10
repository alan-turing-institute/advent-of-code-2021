import unittest
from main import one, find_corrupted, two, find_closings, get_score


subsystem = [
    "[({(<(())[]>[[{[]{<()<>>",
    "[(()[<>])]({[<{<<[]>>(",
    "{([(<{}[<>[]}>{[]{[(<()>",
    "(((({<>}<{<{<>}{[]{[]{}",
    "[[<[([]))<([[{}[[()]]]",
    "[{[{({}]{}}([{[{{{}}([]",
    "{<[[]]>}<{[{[{[]{()[[[]",
    "[<(<(<(<{}))><([]([]()",
    "<{([([[(<>()){}]>(<<{{",
    "<{([{{}}[<[[[<>{}]]]>[]]",
]


class TestOne(unittest.TestCase):
    def test_one(self):
        self.assertEqual(26397, one(subsystem))

    def test_find_corrupted(self):
        self.assertEqual("}", find_corrupted("{([(<{}[<>[]}>{[]{[(<()>"))
        self.assertEqual(")", find_corrupted("[<(<(<(<{}))><([]([]()"))


class TestTwo(unittest.TestCase):
    def test_two(self):
        self.assertEqual(288957, two(subsystem))

    def test_find_closings(self):
        self.assertEqual("]]}}]}]}>", find_closings("{<[[]]>}<{[{[{[]{()[[[]"))
        self.assertEqual(")}>]})", find_closings("[(()[<>])]({[<{<<[]>>("))

    def test_get_score(self):
        self.assertEqual(288957, get_score("}}]])})]"))


if __name__ == "__main__":
    unittest.main()
