import scala.io.Source

val data = Source.fromFile("input.txt").getLines.toVector

def delCompleteBrackets(str: String): String =
    // recursively remove completed brackets until no more remaining
    // Matches (), [], <>, {}
    val newStr = str.replaceAll("""(\(\)|\[\]|<>|\{\})""", "")
    if newStr.length < str.length then
        delCompleteBrackets(newStr)
    else
        newStr

def firstIllegalPoints(leftovers: String): Int =
    // input leftovers should be string after applying delCompleteBrackets
    if leftovers.length == 0 then
        0  // syntax ok     
    else
        // if after removing complete brackets there
        // is something remaining we have a syntax error
        val closeBrackets = List(')', ']', '>', '}')
        leftovers.find(closeBrackets.contains(_)) match
            case Some(')') => 3
            case Some(']') => 57
            case Some('>') => 1197
            case Some('}') => 25137
            case _ => 0  // incomplete line 

def completionScore(incomplete: String): BigInt =
    // Was foiled by overlow again, BigInt to the rescue!
    // close remaining brackets from right to left
    incomplete.foldRight(BigInt(0))(
        (bracket, score) => bracket match
            case '(' => score * 5 + 1
            case '[' => score * 5 + 2
            case '{' => score * 5 + 3
            case '<' => score * 5 + 4
    )

def part1(cleaned: Vector[String]): Int =
    cleaned.foldLeft(0)((sum, str) =>  sum + firstIllegalPoints(str))

def part2(cleaned: Vector[String]): BigInt =
    val incomplete = cleaned.filter(
        str => str.length > 0 && firstIllegalPoints(str) == 0
    )
    val scores = incomplete.map(completionScore(_)).sorted
    println(scores.length)
    println(scores.length / 2)
    scores(scores.length / 2) // middle score

@main def day10() =
    // remove complete brackets from each string
    val cleaned = data.map(delCompleteBrackets(_))

    printf("Part 1: %d\n", part1(cleaned))
    printf("Part 2: %d\n", part2(cleaned))
