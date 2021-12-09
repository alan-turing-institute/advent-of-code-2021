import scala.io.Source

val crabs = Source.fromFile("input.txt")
                  .mkString.split(",")
                  .map(_.trim().toInt).toVector
 
def fuelUsedLinear(alignPos: Int): Int =
    crabs.foldLeft(0)((sumFuel, pos) => sumFuel + (pos - alignPos).abs)

def fuelUsedIncreasing(alignPos: Int): Int =
    def sumN(n: Int): Int = n * (n + 1) / 2
    crabs.foldLeft(0)((sumFuel, pos) => sumFuel + sumN((pos - alignPos).abs))

@main def day7() =
    // brute force between min and max crab positions
    val alignPositions = crabs.min to crabs.max
    val consumpP1 = for p <- alignPositions yield fuelUsedLinear(p)
    val consumpP2 = for p <- alignPositions yield fuelUsedIncreasing(p)
    printf("Part 1: %d\n", consumpP1.min)
    printf("Part 2: %d\n", consumpP2.min)
