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

def bitsToInt(bits: String): Int =
    Integer.parseInt(bits, 2)

def parseType(typeBits: String): String =
    val typeInt = bitsToInt(typeBits)
    typeInt match
        //case 0 => "end"
        case 4 => "literal"
        case _ => "operator"

def parseHeader(bits: String): (Int, String) =
    if bits.length < 8 && bits.forall(_ == '0') then
        (-1, "end")
    else
        val packageVersion = bitsToInt(bits.slice(0, 3))
        val packageType = parseType(bits.slice(3, 6))
        (packageVersion, packageType)

def findEndLiteral(literalNoHeader: String, idx: Int = 0): Int =
    // starting with literal string with header bits removed, recursively
    // parse through the number blocks until we find one that starts with
    // 0, which is the last block, and keep track of the index
    if literalNoHeader(0) == '0' then
        idx + literalBlockSize - 1
    else
        findEndLiteral(literalNoHeader.drop(literalBlockSize), idx + literalBlockSize)

def findEndOperator(operatorNoHeader: String): Int =
    // starting with operator string with header bits removed, returns the
    // last index of the operator definition. I.e. the next index will be
    // the start of the first sub-package in the operator
    if operatorNoHeader(0) == '0' then
        15
    else
        11
        
def countVersions(bits: String, sum: Int = 0): Int =
    val (packageVersion, packageType) = parseHeader(bits)
    val nextIdx = packageType match
        case "literal" => headerBits + findEndLiteral(bits.drop(headerBits))
        case "operator" => headerBits + findEndOperator(bits.drop(headerBits))
        case "end" => -1
    if nextIdx == -1 then
        sum
    else
        //println(bits)
        //printf("t=%s v=%d, n=%d s=%d\n", packageType, packageVersion, nextIdx, sum)
        countVersions(bits.drop(nextIdx + 1), sum + packageVersion)

@main def part1() =
    val hex = Source.fromFile("input.txt").mkString.strip()
    //println(hex)
    val bits = hexToBinary(hex)
    //println(bits)
    printf("Part 1: %d\n", countVersions(bits))
