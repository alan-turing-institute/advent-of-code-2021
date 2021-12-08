import scala.io.Source

val data = Source.fromFile("input.txt").getLines.toVector
                 // split unique patterns from output
                 .map(_.split('|').toVector
                 // split into vector of segment strings and
                 //    sort each segment string alphabetically
                 //    (makes matching up patterns easier)
                 .map(_.trim().split(" ").toVector.map(_.sorted)))


def count1478(segments: String): Int = segments.length match
  case 2 => 1  // 1 has 2 segments
  case 4 => 1  // 4 has 4 segments
  case 3 => 1  // 7 has 3 segments
  case 7 => 1  // 8 haw 7 segments
  case _ => 0


def part1(data: Vector[Vector[Vector[String]]]): Int =
    val output = data.map(_(1)).flatten
    output.foldLeft(0)((sum, newOutput) => sum + count1478(newOutput))


def patternsToInts(patterns: Vector[String]): Map[Int, String] =
    // Convert pattern strings to digits with the most horrific thing I've
    // ever written... don't have time to tidy it up, sorry!
    var patternMap = Map[Int, String]()
    for p <- patterns do
        if p.length == 2 then patternMap += (1 -> p)  // 1 has 2 segments
        if p.length == 3 then patternMap += (7 -> p)  // 7 has 3 segments
        if p.length == 4 then patternMap += (4 -> p)  // 4 has 4 segments
        if p.length == 7 then patternMap += (8 -> p)  // 8 has 7 segments

    var length5Patterns = patterns.filter(_.length == 5)
    // 3 is the only length 5 digit containing both segments in 1
    for p <- length5Patterns do
        if (p contains patternMap(1)(0)) && (p contains patternMap(1)(1)) then
            patternMap += (3 -> p)
    // remove matched string from remaining length5 patterns
    length5Patterns = length5Patterns.filter(_ != patternMap(3))

    var length6Patterns = patterns.filter(_.length == 6)
    // 6 is the only length 6 digit containing only one segment in 1
    for p <- length6Patterns do
        if (p contains patternMap(1)(0)) && (!(p contains patternMap(1)(1))) then
            patternMap += (6 -> p)
            val charIn5 = patternMap(1)(0) // 5 will contain this character
            val charIn2 = patternMap(1)(1) // 2 will contain this character
            // fill 2 and 5
            for p <- length5Patterns do
                if (p contains charIn2) then
                    patternMap += (2 -> p)
                else if (p contains charIn5) then
                    patternMap += (5 -> p)

        else if (!(p contains patternMap(1)(0))) && (p contains patternMap(1)(1)) then
            patternMap += (6 -> p)
            val charIn2 = patternMap(1)(0) // 5 will contain this character
            val charIn5 = patternMap(1)(1) // 2 will contain this character
            // fill 2 and 5
            for p <- length5Patterns do
                if (p contains charIn2) then
                    patternMap += (2 -> p)
                else if (p contains charIn5) then
                    patternMap += (5 -> p)

    // remove matched string from remaining length6 patterns, patterns will be for 0 and 9
    length6Patterns = length6Patterns.filter(_ != patternMap(6))

    // match 0 and 9: 3 contains all thte segments of 9
    for p <- length6Patterns do
        if patternMap(3).forall(p contains _) then
            patternMap += (9 -> p)
        else
            patternMap += (0 -> p)

    patternMap


def part2(data: Vector[Vector[Vector[String]]]): Int =
    val results = for row <- data yield
        val patterns = row(0)
        val outputs = row(1)
        // swap keys to be strings and values the numbers
        val patternMap = patternsToInts(patterns).map(_.swap)
        // map patterns to int, convert vector of int to
        // int via parsinig to string
        outputs.map(patternMap(_)).mkString.toInt

    results.sum


@main def day8() =
    printf("Part 1: %d\n", part1(data))
    printf("Part 2: %d\n", part2(data))
