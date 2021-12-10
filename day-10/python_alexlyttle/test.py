import unittest
from syntax_scoring import score_syntax

TESTINPUT = '[({(<(())[]>[[{[]{<()<>>\n' + \
            '[(()[<>])]({[<{<<[]>>(\n' + \
            '{([(<{}[<>[]}>{[]{[(<()>\n' + \
            '(((({<>}<{<{<>}{[]{[]{}\n' + \
            '[[<[([]))<([[{}[[()]]]\n' + \
            '[{[{({}]{}}([{[{{{}}([]\n' + \
            '{<[[]]>}<{[{[{[]{()[[[]\n' + \
            '[<(<(<(<{}))><([]([]()\n' + \
            '<{([([[(<>()){}]>(<<{{\n' + \
            '<{([{{}}[<[[[<>{}]]]>[]]\n'
             

class TestSyntaxScoring(unittest.TestCase):
    def test_score(self):
        lines = TESTINPUT.splitlines()
        score = score_syntax(lines)
        self.assertEqual(score, (26397, 288957))


if __name__ == '__main__':
    unittest.main()
