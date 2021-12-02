library(testthat)

##### PART ONE #####

test_input <- read.csv(file = "test_input.txt", sep = " ", header = FALSE, col.names = c("direction", "magnitude"))
input <- read.csv("input.txt", sep = " ", header = FALSE, col.names = c("direction", "magnitude"))

compute_horizontal <- function(df) {
  return(sum(df[df$direction=="forward",]$magnitude))
}

compute_depth <- function(df) {
  return(sum(df[df$direction=="down",]$magnitude)-sum(df[df$direction=="up",]$magnitude))
}

# test input
testthat::expect_equal(compute_horizontal(test_input), 15)
testthat::expect_equal(compute_depth(test_input), 10)
testthat::expect_equal(compute_horizontal(test_input)*compute_depth(test_input), 150)

# answer
compute_horizontal(input)*compute_depth(input)

##### PART TWO #####

calculate_location <- function(df) {
  horizontal <- 0
  depth <- 0
  aim <- 0
  for (i in 1:nrow(df)) {
    if (df$direction[i] == "forward") {
      horizontal <- horizontal + df$magnitude[i]
      depth <- depth + (aim*df$magnitude[i])
    } else if (df$direction[i] == "up") {
      aim <- aim - df$magnitude[i]
    } else if (df$direction[i] == "down") {
      aim <- aim + df$magnitude[i]
    }
  }
  return(list('horizontal' = horizontal, 'depth' = depth, 'aim' = aim))
}

# test input
test_output <- calculate_location(test_input)
testthat::expect_equal(test_output$horizontal, 15)
testthat::expect_equal(test_output$depth, 60)
testthat::expect_equal(test_output$horizontal*test_output$depth, 900)

# answer
output <- calculate_location(input)
output$horizontal*output$depth
