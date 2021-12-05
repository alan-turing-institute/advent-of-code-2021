import scala.io.Source
import scala.collection.mutable.ArrayBuffer

type Line = Vector[Vector[Int]]

def loadData(path: String = "input.txt"): Vector[Line] =
    Source.fromFile(path).getLines.map(parseLine).toVector
    
def parseLine(line: String): Line =
    line.split("->").map(_.split(",")).map(_.map(_.trim().toInt).toVector).toVector

def horizontalOrVertical(line: Line): Boolean =
    (line(0)(0) == line(1)(0)) || (line(0)(1) == line(1)(1))

def drawDiagram(lines: Vector[Line]): ArrayBuffer[ArrayBuffer[Int]] =
    val gridSize = lines.flatten.flatten.max +  1
    var grid = ArrayBuffer.fill(gridSize)(ArrayBuffer.fill(gridSize)(0))
    for l <- lines do
        val hDelta = if l(0)(0) > l(1)(0) then -1 else 1
        val vDelta = if l(0)(1) > l(1)(1) then -1 else 1
        val hRange = l(0)(0) to l(1)(0) by hDelta
        val vRange = l(0)(1) to l(1)(1) by vDelta
        if horizontalOrVertical(l) then
            for
                h <- hRange
                v <- vRange
            do
                grid(h)(v) = grid(h)(v) + 1
        else
            for
                i <- 0 to hRange.length - 1
            do
                grid(hRange(i))(vRange(i)) = grid(hRange(i))(vRange(i)) + 1
    grid

def part1(lines: Vector[Line]): Int =
    val diagram = drawDiagram(lines.filter(horizontalOrVertical))
    diagram.flatten.filter(_ > 1).length

def part2(lines: Vector[Line]): Int =
    val diagram = drawDiagram(lines)
    diagram.flatten.filter(_ > 1).length

@main def day5() =
    val data = loadData()
    printf("Part 1: %d\n", part1(data))
    printf("Part 2: %d\n", part2(data))
