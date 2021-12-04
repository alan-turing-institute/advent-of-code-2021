library(testthat)

##### READ IN THE BINGO DATA #####

# returns the bingo numbers as a numeric vector
# returns the bingo cards as a numeric matrix
read_bingo <- function(input) {
  parse <- readLines(input)
  # remove empty lines
  parse <- parse[which(parse!="")]
  # bingo numbers is given in the top line
  # first split the string and convert to numeric vector
  bingo_numbers <- as.numeric(strsplit(parse[1], ",")[[1]])
  # bingo_cards are given by the rest of the lines in parse
  bingo_cards <- lapply(1:(length(parse[-1])/5), function(i) parse[-1][(1:5)+(5*(i-1))])
  # first the strings in each card and remove empty strings
  bingo_cards <- lapply(bingo_cards, function(card) {
    lapply(strsplit(card, " "), function(line) {
      as.numeric(line[which(line!="")])}
    )})
  # convert card into a numeric matrix
  bingo_cards <- lapply(bingo_cards, function(board) matrix(unlist(board), 5, 5))
  return(list('bingo_numbers' = bingo_numbers, 'bingo_cards' = bingo_cards))
}

test_input <- read_bingo("test_input.txt")
input <- read_bingo("input.txt")

##### PART ONE #####

find_winning_board <- function(bingo_numbers, bingo_cards) {
  i <- 1
  no_winner <- TRUE
  while (no_winner) {
    current_number <- bingo_numbers[i]
    bingo_cards <- lapply(bingo_cards, function(mat) {
      mat[which(mat==current_number)] <- -1
      return(mat)
    })
    for (card in bingo_cards) {
      if (any(apply(card, 1, sum)==-5) | any(apply(card, 2, sum)==-5)) {
        winning_card <- card
        no_winner <- FALSE
      }
    }
    i <- i+1
  }
  return(list('winning_number' = current_number,
              'winning_board' = winning_card,
              'final_score' = sum(winning_card[which(winning_card!=-1)])*current_number))
}

# test input
testthat::expect_equal(find_winning_board(test_input$bingo_numbers, test_input$bingo_cards)$winning_number, 24)
testthat::expect_equal(find_winning_board(test_input$bingo_numbers, test_input$bingo_cards)$final_score, 4512)

# answer
find_winning_board(input$bingo_numbers, input$bingo_cards)

##### PART TWO #####

find_losing_board <- function(bingo_numbers, bingo_cards) {
  i <- 1
  winning_board_indices <- rep(FALSE, length(bingo_cards))
  while (!all(winning_board_indices)) {
    current_number <- bingo_numbers[i]
    # only work with boards which haven't won yet
    indices <- which(!winning_board_indices)
    if (length(indices)==1) {
      losing_index <- indices
    }
    # update bingo cards that haven't won yet
    bingo_cards[indices] <- lapply(bingo_cards[indices], function(mat) {
      mat[which(mat==current_number)] <- -1
      return(mat)
    })
    # check if any of the boards that haven't won yet, have now won
    for (c in which(!winning_board_indices)) {
      if (any(apply(bingo_cards[[c]], 1, sum)==-5) | any(apply(bingo_cards[[c]], 2, sum)==-5)) {
        winning_board_indices[c] <- TRUE
      }
    }
    i <- i+1
  }
  return(list('last_winning_number' = current_number,
              'losing_card' = bingo_cards[[c]],
              'final_score' = sum(bingo_cards[[c]][which(bingo_cards[[c]]!=-1)])*current_number))
}

# test input
testthat::expect_equal(find_losing_board(test_input$bingo_numbers, test_input$bingo_cards)$last_winning_number, 13)
testthat::expect_equal(find_losing_board(test_input$bingo_numbers, test_input$bingo_cards)$final_score, 1924)

# answer
find_losing_board(input$bingo_numbers, input$bingo_cards)
