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
      pair <- paste(c(polymer[[i]], polymer[[i+1]]), collapse="")
      new_polymer <- c(new_polymer, replacement[[pair]], polymer[[i+1]])
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

pair_counter <- function(polymer, replacement) {
  pair_count <- rep(0, length(replacement))
  names(pair_count) <- names(replacement)
  for (i in 1:(length(polymer)-1)) {
    pair <- paste(c(polymer[[i]], polymer[[i+1]]), collapse="")
    pair_count[pair] <- pair_count[pair]+1
  }
  return(pair_count)
}

part_two <- function(polymer, replacement, steps) {
  pair_count <- pair_counter(polymer, replacement)
  for (s in 1:steps) {
    new_pair_count <- pair_count
    non_zero_pairs <- which(pair_count!=0)
    for (pair in names(non_zero_pairs)) {
      pair_split <- strsplit(pair, "")[[1]]
      p1 <- paste(c(pair_split[1], replacement[pair]), collapse = "")
      p2 <- paste(c(replacement[pair], pair_split[2]), collapse = "")
      new_pair_count[p1] <- new_pair_count[p1] + pair_count[pair]
      new_pair_count[p2] <- new_pair_count[p2] + pair_count[pair]
      new_pair_count[pair] <- new_pair_count[pair] - pair_count[pair]
    }
    pair_count <- new_pair_count
  }
  # count frequency by looking at the first letter in each pair in the pair count
  frequency <- rep(0, length(unlist(unique(replacement))))
  names(frequency) <- unlist(unique(replacement))
  for (pair in names(pair_count)) {
    first_letter <- strsplit(pair, "")[[1]][1]
    frequency[first_letter] <- frequency[first_letter] + pair_count[pair]
  }
  # last letter in the polymer always stays the same and need to add that to the count
  frequency[polymer[[length(polymer)]]] <- frequency[polymer[[length(polymer)]]]+1
  frequency <- sort(frequency, decreasing = TRUE)
  names(frequency) <- c()
  return(frequency[1]-frequency[length(frequency)])
}

# test part one answer
testthat::expect_equal(part_two(test_input$polymer_template, test_input$replacement, 10), 1588)
testthat::expect_equal(part_two(input$polymer_template, input$replacement, 10), 3247)

# test input
testthat::expect_equal(part_two(test_input$polymer_template, test_input$replacement, 40), 2188189693529)

# answer
print(part_two(input$polymer_template, input$replacement, 40), digits = 13)
