library(testthat)

test_input <- readLines("test_input.txt")
input <- readLines("input.txt")

##### PART ONE #####

find_error <- function(line) {
  open_to_close_bracket <- list("(" = ")",
                                "[" = "]",
                                "{" = "}",
                                "<" = ">")
  line <- strsplit(line, "")[[1]]
  incomplete_brackets <- rep("", length(line))
  i <- 1
  for (char in line) {
    if (char %in% c("(", "[", "{", "<")) {
      # add character to vector of incomplete brackets
      incomplete_brackets[i] <- char
      i <- i+1
    } else if (char %in% c(")", "]", "}", ">")) {
      # check if char closes the bracket that is on the top of the vector
      if (char != open_to_close_bracket[[incomplete_brackets[i-1]]]) {
        return(list('error' = 'corruption',
                    'expected' = open_to_close_bracket[[incomplete_brackets[i-1]]],
                    'found' = char))
      } else {
        incomplete_brackets[i-1] <- ""
        i <- i-1
      }
    }
  }
  incomplete_brackets <- incomplete_brackets[incomplete_brackets!=""]
  # no corruption in line, so return the incomplete brackets (and required brackets to complete)
  return(list('error' = 'incomplete',
              'incomplete_brackets' = incomplete_brackets,
              'to_complete' = rev(sapply(incomplete_brackets, function(brac) open_to_close_bracket[[brac]]))))
}

corruption_score <- function(syntax_errors) {
  syntax_error_score <- list(")" = 3,
                             "]" = 57,
                             "}" = 1197,
                             ">" = 25137)
  score <- 0
  for (line in syntax_errors) {
    error <- find_error(line)
    if (error$error == 'corruption') {
      score <- score + syntax_error_score[[error$found]]
    }
  }
  return(score)
}

# test input
testthat::expect_equal(corruption_score(test_input), 26397)

# answer
corruption_score(input)

##### PART TWO #####

incomplete_score <- function(syntax_errors) {
  char_score <- list(")" = 1,
                     "]" = 2,
                     "}" = 3,
                     ">" = 4)
  scores <- rep(NA, length(syntax_errors))
  i <- 1
  for (line in syntax_errors) {
    error <- find_error(line)
    if (error$error == "incomplete") {
      scores[i] <- 0
      for (char in error$to_complete) {
        scores[i] <- 5*scores[i]
        scores[i] <- scores[i] + char_score[[char]]
      }
      i <- i+1
    }
  }
  scores <- scores[!is.na(scores)]
  return(sort(scores)[ceiling(length(scores)/2)])
}

# test input
testthat::expect_equal(incomplete_score(test_input), 288957)

# answer
incomplete_score(input)
