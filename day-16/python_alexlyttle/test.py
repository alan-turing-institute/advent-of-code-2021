import unittest
from packet_decoder import hex_to_binary, evaluate_packet


class TestDecoder(unittest.TestCase):
    def test_version_1(self):
        packet = hex_to_binary('8A004A801A8002F478')
        version, _ = evaluate_packet(packet)
        self.assertEqual(version, 16)
    def test_version_2(self):
        packet = hex_to_binary('A0016C880162017C3686B18A3D4780')
        version, _ = evaluate_packet(packet)
        self.assertEqual(version, 31)
    def test_eval_1(self):
        packet = hex_to_binary('C200B40A82')
        _, res = evaluate_packet(packet)
        self.assertEqual(res, 3)
    def test_eval_2(self):
        packet = hex_to_binary('CE00C43D881120')
        _, res = evaluate_packet(packet)
        self.assertEqual(res, 9)
    def test_eval_3(self):
        packet = hex_to_binary('9C0141080250320F1802104A08')
        _, res = evaluate_packet(packet)
        self.assertEqual(res, 1)
        

if __name__ == '__main__':
    unittest.main()
