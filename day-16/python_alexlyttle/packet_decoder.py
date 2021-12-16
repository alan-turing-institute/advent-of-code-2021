def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    return s

def hex_to_binary(x):
    """Ensures than the binary contains leading zeros"""
    return bin(int(x, 16))[2:].zfill(len(x)*4)

def decode_literal(packet):
    """Decode a literal packet"""
    i = 0
    value = ''
    while True:
        group = packet[i:i+5]  # each group has 5 bits
        value += group[1:]  # the value is contained in the last 4 bits
        i += 5
        if group[0] == '0':
            break  # the last section is prefixed with a 0 bit
    sub_packet = packet[i:]
    return sub_packet, int(value, 2)  # return remaining sub packet

def decode_operation(packet):
    """Decode an operation packet"""
    case = packet[0]  # first bit determins sub package info
    version = 0  # version counter
    ops = []  # list of operations within packet
    if case == '0':
        # total length of sub packets
        start = 16
        length = int(packet[1:start], 2)
        end = start + length
        sub_packet = packet[start:end]
        while sub_packet:
            # stops when sub_packet is empty string
            sub_packet, v, op = decode_packet(sub_packet)
            version += v
            ops += op
        sub_packet = packet[end:]  # sets sub packet as remaining bits
    elif case == '1':
        # number of sub packets
        start = 12
        num = int(packet[1:start], 2)
        sub_packet = packet[start:]
        for j in range(num):
            # stops after parsing all sub packets
            sub_packet, v, op = decode_packet(sub_packet)
            version += v
            ops += op
    return sub_packet, version, ops
                
def decode_packet(packet):
    """Decode a packet, returning any remaining sub packet, cumulative version
    number, and list of operations."""
    operations = {}
    # Header
    version = int(packet[:3], 2)
    type_id = int(packet[3:6], 2)
    
    # Main
    sub_packet = packet[6:]
    if type_id == 4:
        # literal value
        sub_packet, operations[type_id] = decode_literal(sub_packet)
    else:
        # operator
        sub_packet, v, operations[type_id] = decode_operation(sub_packet)
        version += v
    
    return sub_packet, version, [operations]

def product(x):
    res = 1
    for i in x:
        res *= i
    return res

def greater_than(a, b):
    if a > b:
        return 1
    return 0

def less_than(a, b):
    if a < b:
        return 1
    return 0

def equal_to(a, b):
    if a == b:
        return 1
    return 0

def operation_generator(operations):
    """Generator iterates through operations yielding result(s)
    
    There may be a way to integrate this to the above, but for now it is
    a separate process. Operations could be a longer list, e.g. for 
    """
    for ops in operations:
        for type_id, value in ops.items():
            # This may suit Python 3.10's match case stuff
            if type_id == 0:
                yield sum(operation_generator(value))
            elif type_id == 1:
                yield product(operation_generator(value))
            elif type_id == 2:
                yield min(operation_generator(value))
            elif type_id == 3:
                yield max(operation_generator(value))
            elif type_id == 4:
                yield value
            elif type_id == 5:
                yield greater_than(*operation_generator(value))
            elif type_id == 6:
                yield less_than(*operation_generator(value))
            elif type_id == 7:
                yield equal_to(*operation_generator(value))

def evaluate_packet(packet):
    """Returns the evaluation of a packet"""
    _, total_version, operations = decode_packet(packet)
    res, = tuple(operation_generator(operations))
    return total_version, res

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Evaluate BITS transmission'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')

    args = parser.parse_args()
    x = load_input(args.input_file)
    packet = hex_to_binary(x)
    version, res = evaluate_packet(packet)
    print(f'Total version = {version}')
    print(f'Result = {res}')
