import scala.io.Source

val data = Source.fromFile("input.txt").getLines.toVector
                 .map(_.toVector.map(_.asDigit))

def riskLevel(value: Int): Int =
    value + 1

def getAdjacentIdx(row: Int, column: Int, nRows: Int, nColumns: Int): Vector[Vector[Int]] =
    val adjIdx = for
        hDelta <- List(-1, 0, 1)
        vDelta <- List(-1, 0, 1)
        if hDelta == 0 || vDelta == 0  // don't chcck diagonals
        if !(hDelta == 0 && vDelta == 0)  // don't check self
        if column + hDelta >= 0  // check have left/right neighbours
        if column + hDelta < nColumns
        if row + vDelta >= 0  // check have above/below neighbours
        if row + vDelta < nRows 
    yield
        Vector(row + vDelta, column + hDelta)
    adjIdx.toVector

def getAdjacentValues(row: Int, column: Int, data: Vector[Vector[Int]]): Vector[Int] =
    val adjValues = for
        idx <- getAdjacentIdx(row, column, data.length, data(0).length)
    yield
        data(idx(0))(idx(1))
    adjValues.toVector

def getLowPoints(data: Vector[Vector[Int]]): Vector[Vector[Int]] =
    val nRows = data.length
    val nColumns = data(0).length
    val lowPoints = for
        row <- 0 to nRows - 1
        column <- 0 to nColumns - 1
        if getAdjacentValues(row, column, data).forall(_ > data(row)(column))
    yield
        Vector(row, column)
    lowPoints.toVector

def getBasin(point: Vector[Int], data: Vector[Vector[Int]]): Set[Vector[Int]] =
    // build a basin starting from a point, iteratively adding adjacent points to the
    // basin until 9s are hit
    var basin = Set[Vector[Int]](point)
    var newPoints = Set[Vector[Int]](point)
    while newPoints.size > 0 do
        newPoints = newPoints.map(idx => getAdjacentIdx(idx(0), idx(1), data.length, data(0).length))
                             .flatten  // vector of points for each input, to flat vector of points
                             .diff(basin) // new points are only ones not alread in the basin
                             .filter(idx => data(idx(0))(idx(1)) != 9) // 9s are the edge of the basin
        basin = basin.union(newPoints) // add to basin
    basin

def part1(data: Vector[Vector[Int]]): Int =
    val lowValues = getLowPoints(data).map(idx => data(idx(0))(idx(1))) // convert idx to value
    lowValues.foldLeft(0)((total, value) => total + riskLevel(value))

def part2(data: Vector[Vector[Int]]): Int =
    val lowPoints = getLowPoints(data)
    val basins = for p <- lowPoints yield getBasin(p, data)
    // below assumes each basin only has 1 low point (otherwise
    // the same basin could appear in the basins vector multiple times)
    val basinSizes = basins.map(_.size)
    basinSizes.sorted.slice(basinSizes.length - 3, basinSizes.length).product

@main def day9() =
    getBasin(Vector(4, 6), data)
    printf("Part 1: %d\n", part1(data))
    printf("Part 2: %d\n", part2(data))
