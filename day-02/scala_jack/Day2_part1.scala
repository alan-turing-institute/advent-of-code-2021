import scala.io.Source


def loadData(path: String = "input.txt"): Vector[Vector[Int]] =
    val file = Source.fromFile(path)    
    file.getLines.map(_.split(" ")).map(parseInstruction).toVector
    // should close file here


/** Convert up/down/forward message into a vector of
 *  change in hoizontal posititon and change in depth.
 */
def parseInstruction(instr: Array[String]): Vector[Int] =
    // instr is like ("up", 10)
    instr(0) match
        case "up" => Vector(0, -instr(1).toInt) // decrease depth
        case "down" => Vector(0, instr(1).toInt) // increase depth
        case "forward" => Vector(instr(1).toInt, 0) // increase horizontal position


def sumColumn(values: Vector[Vector[Int]], column: Int): Int =
    // with map:
    //   values.map(x => x(column)).sum
    // with foldLeft:
    //   First argument (0) is start value
    //   total (can be given any name) is running sum so far
    //   row (can be given any name) is the new element to process
    values.foldLeft(0)((total, row) => total + row(column))


@main def day2Part1() =
    val data = loadData()
    val result = sumColumn(data, 0) * sumColumn(data, 1)
    printf("Part 1: %d\n", result)
