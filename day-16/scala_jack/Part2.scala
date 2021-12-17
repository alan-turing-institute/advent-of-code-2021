import scala.io.Source

val hexMap = Map(
    '0' -> "0000",
    '1' -> "0001",
    '2' -> "0010",
    '3' -> "0011",
    '4' -> "0100",
    '5' -> "0101",
    '6' -> "0110",
    '7' -> "0111",
    '8' -> "1000",
    '9' -> "1001",
    'A' -> "1010",
    'B' -> "1011",
    'C' -> "1100",
    'D' -> "1101",
    'E' -> "1110",
    'F' -> "1111"
)
val headerBits = 6
val literalBlockSize = 5

def hexToBinary(hex: String): String =
    hex.map(hexMap(_)).mkString

def bitsToInt(bits: String): BigInt =
    //Integer.parseInt(bits, 2)
    BigInt(bits, 2)

def parseType(typeBits: String): String =
    val typeInt = bitsToInt(typeBits)
    typeInt match
        case 4 => "literal"
        case 0 => "sum"
        case 1 => "product"
        case 2 => "minimum"
        case 3 => "maximum"
        case 5 => "greater_than"
        case 6 => "less_than"
        case 7 => "equal"

def parseHeader(bits: String): (BigInt, String) =
    val packageVersion = bitsToInt(bits.slice(0, 3))
    val packageType = parseType(bits.slice(3, 6))
    (packageVersion, packageType)

def runOperator(packageType: String, values: Vector[BigInt]): BigInt =
    packageType match
        case "sum" => values.sum
        case "product" => values.product
        case "minimum" => values.min
        case "maximum" => values.max
        case "greater_than" => if values(0) > values(1) then BigInt(1) else BigInt(0)
        case "less_than" => if values(0) < values(1) then BigInt(1) else BigInt(0)
        case "equal" => if values(0) == values(1) then BigInt(1) else BigInt(0)

def evaluate(bits: String, idx: Int = 0): (BigInt, Int) =
    val (_, packageType) = parseHeader(bits.slice(idx, idx + headerBits))
    if packageType == "literal" then
        var end = false
        var value = ""
        var newIdx = idx + headerBits
        while !end do
            if bits(newIdx) == '0' then end = true
            value += bits.slice(newIdx + 1, newIdx + literalBlockSize)
            newIdx += literalBlockSize

        (bitsToInt(value), newIdx)

    else
        val lengthType = bits(idx + headerBits)
        var values  = Vector[BigInt]()
        var newIdx = idx

        if lengthType == '0' then
            val startIdx = idx + headerBits + 1 + 15
            val nBits = bitsToInt(bits.slice(idx + headerBits + 1, startIdx))
            val endIdx = startIdx + nBits
            newIdx = startIdx
            while newIdx < endIdx do
                val (value, i) = evaluate(bits, newIdx)
                newIdx = i
                values = values :+ value

        else
            val startIdx = idx + headerBits + 1 + 11
            val nPackets = bitsToInt(bits.slice(idx + headerBits + 1, startIdx))
            newIdx = startIdx
            for _ <- BigInt(1) to nPackets do
                val (value, i) = evaluate(bits, newIdx)
                newIdx = i
                values = values :+ value

        (runOperator(packageType, values), newIdx)

@main def part2() =
    val hex = Source.fromFile("input.txt").mkString.strip()
    val bits = hexToBinary(hex)
    val (result, _) = evaluate(bits)
    printf("Part 2: %d\n", result)

