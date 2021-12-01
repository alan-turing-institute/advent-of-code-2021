import scala.io.Source


def loadData(path: String = "input.txt"): Vector[Int] =
    val file = Source.fromFile(path)    
    val lines = for line <- file.getLines yield line.toInt
    lines.toVector
    // should close file here


def part1(data: Vector[Int]): Int =
    var count = 0
    for
        i <- 1 to (data.length - 1)
        if data(i) - data(i - 1) > 0
    do
        count = count + 1
    return count


def part2(data: Vector[Int], window: Int = 3): Int =
    val sums =
        for
            i <- window to data.length
        yield
            data.slice(i - window, i).sum
    part1(sums.toVector)


@main def day1() =
    val data = loadData()
    printf("Part 1: %d\n", part1(data))
    printf("Part 1: %d\n", part2(data))
