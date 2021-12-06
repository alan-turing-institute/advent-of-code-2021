library(testthat)

test_input <- as.numeric(strsplit(readLines("test_input.txt"), ",")[[1]])
input <- as.numeric(strsplit(readLines("input.txt"), ",")[[1]])

##### PART ONE & TWO #####

simulate_lanternfish <- function(initial_state, n_days) {
  count <- vector("numeric", 9)
  count[1:9] <- sapply(1:9, function(x) sum(initial_state == x-1))
  for (day in 1:n_days) {
    # number of fish that have reached zero
    new_fish <- count[1]
    # update the counts after one day
    for (i in 2:9) {
      count[i-1] <- count[i]
    }
    count[7] <- count[7] + new_fish
    count[9] <- new_fish
  }
  return(sum(count))
}

# test input
testthat::expect_equal(simulate_lanternfish(test_input, 18), 26)
testthat::expect_equal(simulate_lanternfish(test_input, 80), 5934)
testthat::expect_equal(simulate_lanternfish(test_input, 256), 26984457539)

# answer
simulate_lanternfish(input, 80)
print(simulate_lanternfish(input, 256), digits = 22)
