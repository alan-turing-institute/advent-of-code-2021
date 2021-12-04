import scala.io.Source
import scala.collection.mutable.ArrayBuffer


def loadData(path: String = "input.txt"): (Vector[Int], Vector[Bingo]) =
     // Array of one element per section separated by empty line
    val blocks = Source.fromFile(path).mkString.split("(?m)^\\s*$") // multiline REGEX for empty lines 
    // first block is comma separated number draws
    val draws = blocks(0).trim().split(",").map(_.toInt).toVector
    // subsequent blocks are bingo boards
    val boards = blocks.slice(1, blocks.length).map(parseBoard).toVector
    (draws, boards)

def parseBoard(board: String): Bingo =
    val lines = board.trim().split("\\n").map(_.trim()).toVector // one string per board row
    Bingo(lines.map(l => l.split("\\s+").map(_.toInt).toVector)) // split row on whitespace, convert to Int

class Bingo(board: Vector[Vector[Int]]):
    var moves = 0
    var won = false
    val nRows = board.length
    val nCols = board(0).length
    // 2d mutable array of bools for whether number in board marked
    var marked = ArrayBuffer.fill(nRows)(ArrayBuffer.fill(nCols)(false))

    def mark(num: Int): Unit =
        // mark any numbers on the board that match input
        for
            i <- 0 to nRows - 1
            j <- 0 to nCols - 1
            if board(i)(j) == num
        do
            marked(i)(j) = true

    def move(num: Int): Boolean =
        // check whether we have input number and whether we won
        if won then
            true
        else
            moves = moves + 1
            mark(num)
            checkWon()

    def checkWon(): Boolean =
        // check whether any rows or columns are completely marked
        val wonRows = marked.map(_.forall(_ == true)).exists(_ == true)
        val wonColumns = marked.transpose.map(_.forall(_ == true)).exists(_ == true)
        won = wonRows || wonColumns
        won

    def sumUnmarked(): Int =
        // sum all unmarked values on board
        var sum = 0
        for
            i <- 0 to nRows - 1
            j <- 0 to nCols - 1
            if marked(i)(j) == false
        do
            sum = sum + board(i)(j)
        sum

def playGames(draws: Vector[Int], boards: Vector[Bingo]): Vector[Int] =
    var winner = ArrayBuffer.fill(boards.length)(false)
    var d = -1
    while !winner.forall(_ == true) do
        d = d + 1
        winner = boards.map(b => b.move(draws(d))).to(ArrayBuffer)

    boards.map(_.moves) // number of moves each board took to win

def score(board: Bingo, finalNum: Int): Int =
    board.sumUnmarked() * finalNum

@main def day4() =
    val (draws, boards) = loadData()
    val winTime = playGames(draws, boards)
    val fastestBoard = boards(winTime.indexOf(winTime.min))
    val slowestBoard = boards(winTime.indexOf(winTime.max))
    printf("Part 1: %d\n", score(fastestBoard, draws(fastestBoard.moves - 1)))
    printf("Part 2: %d\n", score(slowestBoard, draws(slowestBoard.moves - 1)))
