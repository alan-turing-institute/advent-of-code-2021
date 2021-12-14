library(testthat)

parse_polymer_input <- function(input) {
  lines <- readLines(input)
  polymer_template <- strsplit(lines[[1]], "")[[1]]
  instructions <- strsplit(lines[3:length(lines)], " -> ")
  replacement <- lapply(instructions, function(x) x[2])
  names(replacement) <- sapply(instructions, function(x) x[1])
  return(list('polymer_template' = polymer_template,
              'instructions' = instructions,
              'replacement' = replacement))
}

test_input <- parse_polymer_input("test_input.txt")
input <- parse_polymer_input("input.txt")

##### PART ONE #####

grow_polymer <- function(polymer, replacement, steps) {
  for (s in 1:steps) {
    new_polymer <- c(polymer[[1]])
    for (i in 1:(length(polymer) - 1)) {
      pair <- paste(c(polymer[[i]], polymer[[i + 1]]), collapse="")
      new_polymer <- c(new_polymer, replacement[[pair]], polymer[[i + 1]])
    }
    polymer <- new_polymer
  }
  return(polymer)
}

grow_polymer(test_input$polymer_template, test_input$replacement, 3)

# test input
testthat::expect_equal(paste(grow_polymer(test_input$polymer_template, test_input$replacement, 1), collapse=""), "NCNBCHB")
testthat::expect_equal(paste(grow_polymer(test_input$polymer_template, test_input$replacement, 2), collapse=""), "NBCCNBBBCBHCB")
testthat::expect_equal(paste(grow_polymer(test_input$polymer_template, test_input$replacement, 3), collapse=""), "NBBBCNCCNBBNBNBBCHBHHBCHB")
testthat::expect_equal(paste(grow_polymer(test_input$polymer_template, test_input$replacement, 4), collapse=""), "NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB")

part_one <- function(polymer, replacement, steps) {
  polymer <- grow_polymer(polymer, replacement, steps)
  frequency_table <- sort(table(polymer), decreasing = TRUE)
  names(frequency_table) <- c()
  return(frequency_table[1]-frequency_table[length(frequency_table)])
}

# test input
testthat::expect_equal(part_one(test_input$polymer_template, test_input$replacement, 10), 1588)

# answer
part_one(input$polymer_template, input$replacement, 10)

##### PART TWO #####

# while writing part one, I knew that the cost of growing a vector would catch up to me eventually...
# time to write another solution....
