// really slow but it worked...
import scala.io.Source
import scala.collection.mutable.ArrayBuffer

def getAdjacent(point: Vector[Int], nRows: Int, nCols: Int): Vector[Vector[Int]] =
    val row = point(0)
    val column = point(1)
    val adjIdx = for
        hDelta <- List(-1, 0, 1)
        vDelta <- List(-1, 0, 1)
        if hDelta == 0 || vDelta == 0  // no diagonals
        if !(hDelta == 0 && vDelta == 0)  // not self
        if column + hDelta >= 0  // in horizontal bounds
        if column + hDelta < nCols
        if row + vDelta >= 0  // in vertical bounds
        if row + vDelta < nRows 
    yield
        Vector(row + vDelta, column + hDelta)
    adjIdx.toVector

def getClosestUnvisited(
    distances: ArrayBuffer[ArrayBuffer[Long]],
    unvisited: Set[Vector[Int]],
): Vector[Int] =
    // point in unvisited with min distances(point)
    val unvisitVec = unvisited.toVector
    val unvistDists = unvisitVec.map(p => distances(p(0))(p(1)))
    unvisitVec(unvistDists.indexOf(unvistDists.min))

def getNRowsNColumns(grid: Vector[Vector[Int]]): (Int, Int) =
    (grid.length, grid(0).length)

def dijkstra(
    riskGrid: Vector[Vector[Int]],
    start: Vector[Int],
    end: Vector[Int]
): (ArrayBuffer[ArrayBuffer[Long]], Map[Vector[Int], Vector[Int]]) =
    // this is pretty mmuch copy paste the wikipedia pseudocode for Dijkstra:
    // https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
    val (nRows, nCols) = getNRowsNColumns(riskGrid)
    var distances = ArrayBuffer.fill(nRows)(ArrayBuffer.fill(nCols)(Long.MaxValue))
    distances(start(0))(start(1)) = 0  // no distance to starting point
    var previous = Map[Vector[Int], Vector[Int]]()
    var unvisited = (
        for
            i <- 0 to nRows - 1
            j <- 0 to nCols - 1
        yield
            Vector(i, j)
    ).toSet
    var reachedEnd = false
    var node = start
    
    while !reachedEnd do
        node = getClosestUnvisited(distances, unvisited)
        unvisited -= node
        if node == end then reachedEnd = true

        for
            next <- getAdjacent(node, nRows, nCols)
            if unvisited.contains(next)
        do
            val nextRisk = distances(node(0))(node(1)) + riskGrid(next(0))(next(1))
            if nextRisk < distances(next(0))(next(1)) then              
                distances(next(0))(next(1)) = nextRisk
                previous = previous.updated(next, node)

    (distances, previous)

def expandGrid(riskGrid: Vector[Vector[Int]], times: Int): Vector[Vector[Int]] =
    val (initRows, initCols) = getNRowsNColumns(riskGrid)
    val (bigRows, bigCols) = (initRows * times, initCols * times)
    var bigGrid = ArrayBuffer.fill(bigRows)(ArrayBuffer.fill(bigCols)(0))
    // inefficient repeat grid N times right and down, increasing each block by 1
    // top left is initial riskGrid
    for
        i <- 0 to (initRows - 1)
        j <- 0 to (initCols - 1)
    do
        bigGrid(i)(j) = riskGrid(i)(j)
    // copy down to bottom, incrementing each block by 1
    for
        i <- initRows to (bigRows - 1)
        j <- 0 to (initCols - 1)
    do
        bigGrid(i)(j) = bigGrid(i - initRows)(j) + 1
    // copy across to right, incrementing each block by 1
    for
        i <- 0 to (bigRows - 1)
        j <- initCols to (bigCols - 1)
    do
        bigGrid(i)(j) = bigGrid(i)(j - initCols) + 1
    // wrap greater than 0
    bigGrid = bigGrid.map(
        row => row.map(
            value => if value % 9 == 0 then 9 else value % 9
        )
    )
    // convert to vector for compatibility with other functions
    bigGrid.map(_.toVector).toVector

def part1(riskGrid: Vector[Vector[Int]]): Long =
    val (nRows, nCols) = getNRowsNColumns(riskGrid)
    val start = Vector(0, 0)
    val end = Vector(nRows - 1, nCols - 1)
    val (distances, previous) = dijkstra(riskGrid, start, end)
    distances(end(0))(end(1))

def part2(riskGrid: Vector[Vector[Int]]): Long =
    val bigGrid = expandGrid(riskGrid, 5)
    val nRows = bigGrid.length
    val nCols = bigGrid(0).length
    val start = Vector(0, 0)
    val end = Vector(nRows - 1, nCols - 1)
    val (distances, previous) = dijkstra(bigGrid, start, end)
    distances(end(0))(end(1))

@main def day15() =
    val riskGrid = Source.fromFile("input.txt").getLines.toVector
                     .map(_.toVector.map(_.asDigit))
    printf("Part 1: %d\n", part1(riskGrid))
    printf("Part 2: %d\n", part2(riskGrid))
