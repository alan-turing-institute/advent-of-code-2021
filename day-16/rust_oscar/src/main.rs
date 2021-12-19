fn main() {
    println!("Hello, world!");
}

// 1. Translate everything from Hex to Bits
// The BITS transmission contains a single packet at its outermost layer which itself contains many other packets.
// The hexadecimal representation of this packet might encode a few extra 0 bits at the end; these are not part of the transmission and should be ignored.

// Every packet begins with a standard header: the first three bits encode the packet version, and the next three bits encode the packet type ID
// type ID 4 represent a literal value.

// Literal Value: a single binary number.
// the binary number is padded with leading zeroes until its length is a multiple of four bits, and then it is broken into groups of four bits.
// Each group is prefixed by a 1 bit except the last group, which is prefixed by a 0 bit. T
// These groups of five bits immediately follow the packet header.

// All other types: Operator
// An operator packet contains one or more packets.
// an operator packet can use one of two modes indicated by the bit immediately after the packet header; this is called the length type ID:

// If the length type ID is 0, then the next 15 bits are a number that represents the total length in bits of the sub-packets contained by this packet.
// If the length type ID is 1, then the next 11 bits are a number that represents the number of sub-packets immediately contained by this packet
// Finally, after the length type ID bit and the 15-bit or 11-bit field, the sub-packets appear.

#[derive(Debug, PartialEq)]
struct Packet {
    version: u8,
    type_id: u8,
    payload: Payload,
}

impl Packet {
    fn new(version: u8, type_id: u8, payload: Payload) -> Self {
        Packet {
            version,
            type_id,
            payload,
        }
    }
}

fn parse_header(packet_bits: &str, cursor: usize) -> ((u8, u8), usize) {
    let version = &packet_bits[cursor..cursor + 3];
    let type_id = &packet_bits[cursor + 3..cursor + 6];
    ((bits_to_u8(version), bits_to_u8(type_id)), cursor + 6)
}

fn parse_literal(packet_bits: &str, cursor: usize) -> (Payload, usize) {
    let mut cursor = cursor;
    let mut last_byte = false;
    let mut payload = String::new();

    while !last_byte {
        if &packet_bits[cursor..cursor + 1] == "0" {
            last_byte = true;
        };
        payload.push_str(&packet_bits[cursor + 1..cursor + 5]);
        cursor += 5;
    }
    (Payload::Literal(bits_to_u64(&payload)), cursor)
}

fn parse_length_type(packet_bits: &str, cursor: usize) -> (OperatorType, usize) {
    let length_type_bit = &packet_bits[cursor..cursor + 1];
    match length_type_bit {
        "0" => (
            OperatorType::N_bits(BitCount {
                cursor_start: cursor + 15,
                n_bits: bits_to_u8(&packet_bits[cursor + 1..cursor + 1 + 15]) as usize,
                n_read: 0
            }),
            cursor + 1 + 15,
        ),
        "1" => (
            OperatorType::N_packets(bits_to_u8(&packet_bits[cursor + 1..cursor + 1 + 11]) as usize),
            cursor + 1 + 11,
        ),
        _ => panic!("Not a valid bit"),
    }
}
fn parse_packet(packet_bits: &str) -> Packet {
    let mut cursor = 0;

    let mut stack: Vec<PayloadParser> = Vec::new();

    loop {

        loop {
            let last_payload_parser = stack.last();

            if last_payload_parser.is_none() {
                break;
            }

            let last_payload_parser = last_payload_parser.unwrap();

            if last_payload_parser.is_parsed(cursor) {

                // Take ownership
                let last_payload_parser = stack.pop().unwrap();
                let last_packet = last_payload_parser.packet;

                let stack_len = stack.len();

                if stack_len == 0 {
                    return last_packet;
                }

                // Get mutable reference to last operator PayloadParser
                let preceeding_parser = stack
                    .iter_mut()
                    .rev()
                    .filter(|parser| {
                        if let Payload::Operator(_) = parser.packet.payload {
                            true
                        } else {
                            false
                        }
                    })
                    .next()
                    .unwrap();
                preceeding_parser.add_payload(last_packet, cursor);
            } else {
                break;
            }
        }

        if cursor == packet_bits.len() {
            return stack.pop().unwrap().packet;
        }

        let ((version, type_id), c_new) = parse_header(packet_bits, cursor);
        cursor = c_new;
        let c_new = match type_id {
            4 => {
                // parse literal package
                let (payload, c_new) = parse_literal(packet_bits, cursor);
                stack.push(PayloadParser::new(
                    Packet::new(version, type_id, payload),
                    None,
                ));
                c_new
            }
            _ => {
                // Parse operator packet
                let (operator_type, c_new) = parse_length_type(packet_bits, cursor);
                let packet = Packet::new(version, type_id, Payload::Operator(Vec::new()));
                stack.push(PayloadParser::new(packet, Some(operator_type)));
                c_new
            }
        };
        cursor = c_new;

        // println!("{:?}", cursor);
        // println!("{:?}", stack);
    }
}

#[derive(Debug, PartialEq)]
enum Payload {
    Literal(u64),
    Operator(Vec<Packet>),
}

#[derive(Debug, PartialEq)]
struct BitCount {
    cursor_start: usize,
    n_bits: usize,
    n_read: usize,
}

#[derive(Debug, PartialEq)]
enum OperatorType {
    N_packets(usize),
    N_bits(BitCount),
}

#[derive(Debug, PartialEq)]
struct PayloadParser {
    packet: Packet,
    operator_info: Option<OperatorType>,
}

impl PayloadParser {
    fn new(packet: Packet, operator_info: Option<OperatorType>) -> Self {
        Self {
            packet,
            operator_info,
        }
    }

    /// Check if a PayloadParser has finished parsing
    fn is_parsed(&self, cursor: usize) -> bool {
        match &self.operator_info {
            None => true,
            Some(op_type) => match op_type {
                OperatorType::N_bits(bit_count)
                    if bit_count.n_bits == bit_count.n_read => true,
                OperatorType::N_packets(n_packets) if n_packets == &0 => true,
                _ => false,
            },
        }
    }

    fn add_payload(&mut self, packet: Packet, cursor: usize) {
        // Add the payload
        match &mut self.packet.payload {
            Payload::Operator(children) => {
                children.push(packet);
            }
            _ => panic!("Can only add payload to an operator"),
        };

        // Increment the operator information
        match &mut self.operator_info {
            Some(OperatorType::N_packets(n_packets)) => {
                *n_packets -= 1;
            }
            Some(OperatorType::N_bits(bit_count)) => {
                // Think this is right... but should check

                bit_count.n_read = cursor - bit_count.cursor_start - 1;

                println!("{}, {}", bit_count.n_read, bit_count.n_bits)
                // bit_count.n_bits -= (cursor - bit_count.cursor_start);
                // bit_count.cursor_start = cursor - 1;
            }
            None => panic!("Should be an operator"),
        }
    }
}

fn hex_to_bits(input: &str) -> String {
    let mut bit_string = String::new();
    for i in (0..input.len()).step_by(2) {
        bit_string.push_str(&format!(
            "{:0>8b}",
            u8::from_str_radix(&input[i..i + 2], 16).unwrap()
        ));
    }
    bit_string
}

fn bits_to_u8(bit_string: &str) -> u8 {
    u8::from_str_radix(bit_string, 2).unwrap()
}

fn bits_to_u64(bit_string: &str) -> u64 {
    u64::from_str_radix(bit_string, 2).unwrap()
}

#[cfg(test)]
mod tests {

    use super::*;

    const EXAMPLE: &str = "";

    #[test]
    fn test_parse() {
        assert_eq!("110100101111111000101000", hex_to_bits("D2FE28"));
    }

    #[test]
    fn test_parse_literal_packet() {
        let bits = "110100101111111000101000";
        let ((version, type_id), cursor) = parse_header(bits, 0);
        assert_eq!(version, 6);
        assert_eq!(type_id, 4);
        let (literal, _) = parse_literal(bits, cursor);
        assert_eq!(Payload::Literal(2021), literal);
    }

    #[test]
    fn test_debug() {
        const EXAMPLE2: &str = "Hello";
        let p = Packet {
            version: 5,
            type_id: 5,
            payload: Payload::Literal(3200),
        };
        println!("{:?}", p);
    }

    #[test]
    fn test_parse_operating_n_bits() {
        let root = parse_packet(&"00111000000000000110111101000101001010010001001000000000");
        println!("{:?}", root);
        println!("END")
    }

    #[test]
    fn test_parse_operating_two_n_packet() {
        let root = parse_packet(&"11101110000000001101010000001100100000100011000001100000");
        println!("{:?}", root);
        println!("END")
    }

    #[test]
    fn test_parse_recursive_example() {

        let root = parse_packet(&hex_to_bits("8A004A801A8002F478"));
        println!("{:?}", root);
        println!("END")
    }

    #[test]
    fn test_parse_recursive_example2() {
        let root = parse_packet(&hex_to_bits("620080001611562C8802118E34"));
        println!("{:?}", root);
        println!("END")
    }

    #[test]
    fn test_parse_recursive_example3() {
        let root = parse_packet(&hex_to_bits("C0015000016115A2E0802F182340"));
        println!("{:?}", root);
        println!("END")
    }

    #[test]
    fn test_parse_recursive_example4() {
        let root = parse_packet(&hex_to_bits("A0016C880162017C3686B18A3D4780"));
        println!("{:?}", root);
        println!("END")
    }
}
