/** This took me a long time and I'm sure I'm committing a lot
 * of Scala atrocities (or just atrocities in general)!
 * 
 * Note that the bits Vector[Vector[Int]] 2D arrays are
 * bit position first axis and row number second axis,
 * so e.g. input data of 110, 001, 010 becomes
 * Vector(Vector(1,0,0), Vector(1,0,1), Vector(0,1,0))
 */
import scala.io.Source

/** Loads rows in file like "1011" to a vector of vectors like
 * Vector(1, 0, 1, 1)
 */
def loadData(path: String = "input.txt"): Vector[Vector[Int]] =
    val file = Source.fromFile(path)
    file.getLines
        .map(strToInts)
        .toVector

def strToInts(str: String): Vector[Int] =
    str.toVector.map(_.asDigit)

/** bitVector is like Vector(1, 0, 1, 1), sum is greater than
 * half the length if most common digit is 1.
 */
def mostCommon(bitVector: Vector[Int]): Int =
    if bitVector.sum >= bitVector.length / 2.0 then 1 else 0

def leastCommon(bitVector: Vector[Int]): Int =
    flipBit(mostCommon(bitVector))

def flipBit(bit: Int): Int =
    if bit == 0 then 1 else 0

/** get index of all items with value matchValuue in vector
 * values
 */
def getMatchIdx(values: Vector[Int], matchValue: Int): Vector[Int] =
    val matchIdx = for
        i <- 0 to (values.length - 1)
        if values(i) == matchValue
    yield i
    matchIdx.toVector

/** Utility function to compute Oxygen Generator and CO2 scrubber ratings (depending
 * on method used as bitCriteria).
 */
def getRating(bits: Vector[Vector[Int]], bitCriteria: (Vector[Int]) => Int): Vector[Int] =
    // don't know how to do this without mutables/loops
    var bitPosition = 0 // stores bit index
    var matches: Vector[Int] = Vector() // stores indices to keep
    var result = bits  // stores remaining bits
    while
        matches.length != 1
    do
        // whether we are keeping values with 0 or 1 at this index
        // (i.e. which value is most common for Oxy Generator, or
        // least common for CO2 scrubber)
        val matchValue = bitCriteria(result(bitPosition))

        // indices of the remaining input bits that have the value
        // we're looking for in this position
        matches = getMatchIdx(result(bitPosition), matchValue)

        // filter remaining bits to only keep matches
        result = result.map(x => matches.map(x(_)))

        bitPosition = bitPosition + 1

    // result will be like Vector(Vector(0), Vector(1), Vector(0)),
    // flatten it to Vector(0, 1, 0)
    result = result.transpose
    result(0)

def oxyGen(bits: Vector[Vector[Int]]): Int =
    bitVectorToInt(getRating(bits, mostCommon))

def co2Scrubber(bits: Vector[Vector[Int]]): Int =
    bitVectorToInt(getRating(bits, leastCommon))

/** e.g. Vector(1, 0, 1) -> "101" -> 5
 */
def bitVectorToInt(bitVector: Vector[Int]): Int =
    // 
    Integer.parseInt(bitVector.mkString(""), 2)

def part1(bits: Vector[Vector[Int]]): Int =
    val gamma = bits.map(b => mostCommon(b))
    val epsilon = gamma.map(flipBit)
    bitVectorToInt(gamma) * bitVectorToInt(epsilon)

def part2(bits: Vector[Vector[Int]]): Int =
    val oxy = oxyGen(bits)
    val co2 = co2Scrubber(bits)
    oxy * co2

@main def day3() =
    // transpose to swap one vector per row in file to one vector per bit position
    // e.g. if input is 101, 111, 000 then bits is (1,1,0), (0,1,0), (1,1,0)
    // (values of 1st, 2nd and 3rd bit for each row respectively)
    val bits = loadData().transpose
    printf("Part 1: %d\n", part1(bits))
    printf("Part 2: %d\n", part2(bits))
