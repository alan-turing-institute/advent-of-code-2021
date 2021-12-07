library(testthat)

test_input <- as.numeric(strsplit(readLines('input_test.txt'), ',')[[1]])
input <- as.numeric(strsplit(readLines('input.txt'), ',')[[1]])

##### PART ONE & TWO #####

compute_minimum_cost <- function(initial_state, constant_cost) {
  potential_positions <- min(initial_state):max(initial_state)
  if (constant_cost) {
    # PART ONE: constant cost for movement
    differences <- sapply(potential_positions, function(pos) sum(abs(initial_state-pos)))
  } else {
    # PART TWO: increasing cost for movement
    differences <- sapply(potential_positions, function(pos) {
      sum(sapply(abs(initial_state-pos), function(diff) sum(1:diff)))})
  }
  minimum_cost_position <- potential_positions[which(differences==min(differences))]
  return(list('position' = minimum_cost_position,
              'fuel_spend' = min(differences)))
}

# test input
testthat::expect_equal(compute_minimum_cost(test_input, TRUE)$position, 2)
testthat::expect_equal(compute_minimum_cost(test_input, TRUE)$fuel_spend, 37)
testthat::expect_equal(compute_minimum_cost(test_input, FALSE)$position, 5)
testthat::expect_equal(compute_minimum_cost(test_input, FALSE)$fuel_spend, 168)

# answer
compute_minimum_cost(input, TRUE)
compute_minimum_cost(input, FALSE)
