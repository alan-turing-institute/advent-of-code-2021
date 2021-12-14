import scala.io.Source
import scala.collection.mutable.ArrayBuffer

val data = Source.fromFile("input.txt").getLines.toVector
val foldRegex = """(x|y)=(\d+)""".r  // x=123 or y=123
val folds = data.filter(_.startsWith("fold along "))
                .map(foldRegex.findAllIn(_).subgroups)
                .map(m => (m(0), m(1).toInt))
                .toVector
val points = data.filter(_.contains(","))
                 .map(_.split(",").map(_.toInt).toVector)
                 .toSet

def foldX(p: Vector[Int], x: Int): Vector[Int] =
    if p(0) <= x then
        p
    else
        Vector(2*x - p(0), p(1))

def foldY(p: Vector[Int], y: Int): Vector[Int] =
    if p(1) <= y then
        p
    else
        Vector(p(0), 2*y - p(1))

def applyFold(fold: (String, Int), points: Set[Vector[Int]]): Set[Vector[Int]] =
    val newPoints = for p <- points yield
        if fold(0) == "x" then
            foldX(p, fold(1))
        else
            foldY(p, fold(1))
    newPoints.toSet

def displayPoints(points: Set[Vector[Int]]): Unit =
    val nCols = points.map(p => p(0)).max + 1
    val nRows = points.map(p => p(1)).max + 1  
    var grid = ArrayBuffer.fill(nRows)(ArrayBuffer.fill(nCols)(" "))
    for p <- points do
        grid(p(1))(p(0)) = "#"
    for g <- grid do
        println(g.mkString)

def part1(): Int =
    applyFold(folds(0), points).size

def part2(): Unit =
    var finalPoints = points
    for f <- folds do
        finalPoints = applyFold(f, finalPoints)
    displayPoints(finalPoints)

@main def day13() =
    printf("Part 1: %d\n", part1())
    printf("Part 2:\n")
    part2()
