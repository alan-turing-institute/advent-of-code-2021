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
    // point in unvisited with min distances[point]  
    val unvisitVec = unvisited.toVector
    val unvistDists = unvisitVec.map(p => distances(p(0))(p(1)))
    unvisitVec(unvistDists.indexOf(unvistDists.min))

def dijkstra(
    riskGrid: Vector[Vector[Int]],
    start: Vector[Int],
    end: Vector[Int]
): (ArrayBuffer[ArrayBuffer[Long]], Map[Vector[Int], Vector[Int]]) =

    val nRows = riskGrid.length
    val nCols = riskGrid(0).length
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


@main def day15() =
    val riskGrid = Source.fromFile("input.txt").getLines.toVector
                     .map(_.toVector.map(_.asDigit))
    val nRows = riskGrid.length
    val nCols = riskGrid(0).length
    val start = Vector(0, 0)
    val end = Vector(nRows - 1, nCols - 1)
    val (distances, previous) = dijkstra(riskGrid, Vector(0, 0), Vector(nRows - 1, nCols - 1))
    
    printf("Part 1: %d\n", distances(end(0))(end(1)))
    printf("Part 2: %d\n", 2)
