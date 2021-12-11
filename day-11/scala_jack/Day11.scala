// need to learn how to do this how Scala wants (functional & immutables)
import scala.io.Source
import scala.annotation.tailrec
import scala.collection.mutable.ArrayBuffer

val octopus = Source.fromFile("input.txt").getLines
                    .map(_.to(ArrayBuffer).map(_.asDigit))
                    .to(ArrayBuffer)

def getAdjacentIdx(row: Int, column: Int, nRows: Int, nColumns: Int): Vector[Vector[Int]] =
    val adjIdx = for
        hDelta <- List(-1, 0, 1)
        vDelta <- List(-1, 0, 1)
        if !(hDelta == 0 && vDelta == 0)  // don't check self
        if column + hDelta >= 0  // check have left/right neighbours
        if column + hDelta < nColumns
        if row + vDelta >= 0  // check have above/below neighbours
        if row + vDelta < nRows 
    yield
        Vector(row + vDelta, column + hDelta)
    adjIdx.toVector

@tailrec
def flash(octopus: ArrayBuffer[ArrayBuffer[Int]],
          flashIdx: Set[Vector[Int]] = Set[Vector[Int]]()
): (ArrayBuffer[ArrayBuffer[Int]], Set[Vector[Int]]) =
    val nRows = octopus.length
    val nColumns = octopus(0).length
    var newFlashes = Set[Vector[Int]]()
    for
        row <- 0 to nRows - 1
        column <- 0 to nColumns - 1
        if octopus(row)(column) > 9 && !flashIdx.contains(Vector(row, column))
    do
        newFlashes += Vector(row, column)
        val adjacents = getAdjacentIdx(row, column, nRows, nColumns)
        for idx <- adjacents do
            octopus(idx(0))(idx(1)) += 1
    if newFlashes.size > 0 then
        // got some new octopus to flash
        flash(octopus, flashIdx.union(newFlashes))
    else
        (octopus, flashIdx)

def step(octopus: ArrayBuffer[ArrayBuffer[Int]]): (ArrayBuffer[ArrayBuffer[Int]], Int) =
    // increrment energy then run and count flashes
    val (newOctopus, flashIdx) = flash(octopus.map(_.map(_ + 1)))
    // reset 9s and return new octopus energies and flash count
    (newOctopus.map(_.map(energy => if energy > 9 then 0 else energy)),  flashIdx.size)

def part1(octopus: ArrayBuffer[ArrayBuffer[Int]]): Int =
    var totalFlash = 0
    var newOctopus = octopus.clone
    for i <- 1 to 100 do
        val update = step(newOctopus)
        newOctopus = update(0)
        totalFlash += update(1)
    totalFlash

def part2(octopus: ArrayBuffer[ArrayBuffer[Int]]): Int =
    var newOctopus = octopus.clone
    val nOctopus = octopus.length * octopus(0).length
    var allFlash = false
    var i = 0
    while !allFlash do
        i += 1
        val update = step(newOctopus)
        newOctopus = update(0)
        if update(1) == nOctopus then allFlash = true
    i

@main def day11() =
    printf("Part 1: %d\n", part1(octopus))
    printf("Part 2: %d\n", part2(octopus))
