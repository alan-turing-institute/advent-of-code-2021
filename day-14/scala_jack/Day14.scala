import scala.io.Source

val data = Source.fromFile("input.txt").getLines
val template = data.next
val _ = data.next // skip empty line

// create map of input pair to pairs created after insertion
// e.g. AB -> C becomes AB -> Vector(AC, CB)
val rules = (for line <- data yield
    line.split(" -> ")
).foldLeft(Map[String, Vector[String]]())(
    // r is the rules map (in progress of being built)
    // line is an array like (AB, C)
    (r, line) => r + (line(0) -> Vector(  // AB ->
        line(0)(0).toString + line(1),  // AC
        line(1) + line(0)(1).toString  // CB
    ))
)

def countPairs(template: String): Map[String, BigInt] =
    // list of character pairs in template
    val pairs = for idx <- 0 to template.length - 2 yield
        template.slice(idx, idx+2)
    // create map of pair counts, BigInt just in case counts get large...
    pairs.foldLeft(Map[String, BigInt]().withDefaultValue(BigInt(0)))(
        (total, p) => total.updated(p, total(p) + BigInt(1))
    )

def stepOnce(pairCounts: Map[String, BigInt]): Map[String, BigInt] =
    var newCounts = Map[String, BigInt]().withDefaultValue(BigInt(0))
    for
        (initPair, count) <- pairCounts
        insertPair <- rules(initPair)
    do
        newCounts = newCounts.updated(insertPair, newCounts(insertPair) + count)

    newCounts

def nSteps(pairCounts: Map[String, BigInt], n: Int): Map[String, BigInt] =
    var newCounts = pairCounts
    for _ <- 1 to n do
        newCounts = stepOnce(newCounts)
    newCounts

def pairsToChars(pairCounts: Map[String, BigInt], lastChar: Char): Map[Char, BigInt] =
    var charCounts = Map[Char, BigInt]().withDefaultValue(BigInt(0))
    for
        (pair, count) <- pairCounts
    do
        charCounts = charCounts.updated(pair(0), charCounts(pair(0)) + count)
    // last character always stays the same and isn't included in a pair
    charCounts = charCounts.updated(lastChar, charCounts(lastChar) + 1)
    charCounts

def mostLeastDiff(pairCounts: Map[String, BigInt], lastChar: Char, n: Int) =
    val endCounts = nSteps(pairCounts, n)
    val counts = pairsToChars(endCounts, lastChar)
    counts.values.max - counts.values.min

@main def day14() =
    val pairCounts = countPairs(template)
    val lastChar = template.last
    printf("Part 1: %d\n", mostLeastDiff(pairCounts, lastChar, 10))
    printf("Part 2: %d\n", mostLeastDiff(pairCounts, lastChar, 40))
