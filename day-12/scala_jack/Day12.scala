// need to learn how to do this how Scala wants (functional & immutables)
import scala.io.Source
import scala.annotation.tailrec

val data = Source.fromFile("input.txt").getLines
                 .map(_.split("-").toVector)
                 .toVector

val caves = data.flatten.toSet
val caveMap = caves.map(c => (c, getDestinations(c))).toMap
val smallCave = caves.map(c => (c, isSmallCave(c))).toMap

def getDestinations(cave: String): Set[String] =
    val destinations = for
        link <- data
        if link.contains(cave)
    yield
        if link(0) == cave then link(1) else link(0)
    destinations.toSet

def isSmallCave(cave: String): Boolean =
    cave.forall(_.isLower)

def isValidDest(dest: String, path: Vector[String], smallRevisits: Int): Boolean =
    // can we go to the dest cave after following path if we're
    // allowed to revisit small caves small revisits times
    if !path.contains(dest) || !smallCave(dest) then
        true
    else if dest != "start" &&
            (path.filter(smallCave(_)).toSet.size >
             path.filter(smallCave(_)).length - smallRevisits)
    then
        // not going back to start and not exceeded small visits quota
        true
    else false

def continuePaths(paths: Vector[Vector[String]], smallRevisits: Int) =
    // returns vector of possible next steps (updated paths) for a
    // vector of initial parts (or an empty vector if there are no
    // valid next steps for any of the paths)
    for
        p <- paths
        dest <- caveMap(p.last)
        if isValidDest(dest, p, smallRevisits)
    yield
        p :+ dest

def countPaths(smallRevisits: Int): Int =
    var paths = Vector(Vector("start"))  // start at the start...
    var completePaths = Vector[Vector[String]]()
    while paths.length > 0 do  // found some valid destinations to extend paths
        paths = continuePaths(paths.filter(_.last != "end"), smallRevisits)
        completePaths = completePaths ++ paths.filter(_.last == "end")
    completePaths.length

def part1(): Int =
    countPaths(smallRevisits=0)

def part2(): Int =
    countPaths(smallRevisits=1)

@main def day12() =
    printf("Part 1: %d\n", part1())
    printf("Part 2: %d\n", part2())
