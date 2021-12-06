import scala.io.Source
import scala.collection.mutable.ArrayBuffer

val newFishDays = 8
val resetFishDays = 6

def loadData(path: String = "input.txt"): ArrayBuffer[Int] =
    Source.fromFile(path).mkString.split(",").map(_.trim().toInt).to(ArrayBuffer)

def part1(fish: ArrayBuffer[Int]): Int =
    var newFish = fish
    for day <- 1 to 80 do
        newFish = newFish.map(_ - 1)
        newFish = newFish ++ ArrayBuffer.fill(newFish.count(_ == -1))(newFishDays)
        newFish = newFish.map(d => if d == -1 then resetFishDays else d)
    newFish.length

def part2(fish: ArrayBuffer[Int]): Long =
    // count of fish by number of days remaining
    val intFishCounts = for d <- 0 to newFishDays yield fish.count(_ == d)
    // convert int ArrayBuffer to Long (must be a better way to do this...)
    var fishCounts = intFishCounts.map(_.toLong).to(ArrayBuffer)
    for day <- 1 to 256 do
        // shift days left, moving fish at 0 to end
        // (has effect of creating child fish at newFishDays, 1 per parent)
        fishCounts = fishCounts.addOne(fishCounts.remove(0))
        // add parent fish back in at resetDays (same number as children)
        fishCounts(resetFishDays) += fishCounts.last

    fishCounts.sum

@main def day6() =
    val fish = loadData()
    printf("Part 1: %d\n", part1(fish))
    printf("Part 2: %d\n", part2(fish))
