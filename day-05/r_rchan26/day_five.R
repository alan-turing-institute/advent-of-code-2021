library(testthat)

test_input <-lapply(strsplit(readLines("test_input.txt"), " -> "), function(x) strsplit(x, ","))
input <- lapply(strsplit(readLines("input.txt"), " -> "), function(x) strsplit(x, ","))

##### PART ONE & TWO #####

danger_zoneee <- function(lines, part_two = FALSE) {
  # create matrix to represent the grid
  # +1 since R indices start from 1
  n <- max(as.numeric(unlist(lines))) + 1
  M <- matrix(0, nrow = n, ncol = n)
  for (line in lines) {
    start <- as.numeric(line[[1]]) + 1
    end <- as.numeric(line[[2]]) + 1
    if (!part_two) {
      # if part_two == FALSE, only check horizontal lines
      if(start[1] == end[1]){
        M[seq(start[2], end[2]), start[1]] <- M[seq(start[2], end[2]), start[1]] + 1
      } else if(start[2] == end[2]){ 
        M[start[2], seq(start[1], end[1])] <- M[start[2], seq(start[1], end[1])] + 1
      }
    } else if (part_two) {
      # if part_two == TRUE, check diagonal lines in addition to horizontal
      M[cbind(seq(start[2], end[2]), seq(start[1], end[1]))] <-  M[cbind(seq(start[2], end[2]), seq(start[1], end[1]))] + 1
    }
  }
  return(list('M' = M, 'danger' = sum(M>=2)))
}

# test input
testthat::expect_equal(danger_zoneee(test_input, part_two = FALSE)$danger, 5)
testthat::expect_equal(danger_zoneee(test_input, part_two = TRUE)$danger, 12)

# answer
danger_zoneee(input, part_two = FALSE)$danger
danger_zoneee(input, part_two = TRUE)$danger
