library(testthat)

test_input <- do.call(rbind, strsplit(readLines('test_input.txt'), ""))
test_input <- matrix(as.numeric(test_input), nrow = nrow(test_input), ncol = ncol(test_input))
input <- do.call(rbind, strsplit(readLines('input.txt'), ""))
input <- matrix(as.numeric(input), nrow = nrow(input), ncol = ncol(input))

##### PART ONE #####

find_neighbours <- function(point, nrows, ncols) {
  neighbours <- matrix(nrow = 8, ncol = 2)
  # adjacent neighbours
  neighbours[1,] <- c(point[1]-1, point[2])
  neighbours[2,] <- c(point[1]+1, point[2])
  neighbours[3,] <- c(point[1], point[2]-1)
  neighbours[4,] <- c(point[1], point[2]+1)
  # diagonal neighbours
  neighbours[5,] <- c(point[1]-1, point[2]+1)
  neighbours[6,] <- c(point[1]+1, point[2]+1)
  neighbours[7,] <- c(point[1]+1, point[2]-1)
  neighbours[8,] <- c(point[1]-1, point[2]-1)
  return(neighbours[apply(cbind(neighbours >= 1, cbind(neighbours[,1] <= nrows, neighbours[,2] <= ncols)), 1, all),])
}

update_energy_levels <- function(octopi) {
  flashes <- 0
  octopi <- octopi + 1
  flash_indices <- which(octopi>=10, arr.ind = TRUE)
  while (nrow(flash_indices) > 0) {
    flashes <- flashes + nrow(flash_indices)
    octopi[flash_indices] <- 0
    for (i in 1:nrow(flash_indices)) {
      nbs <- find_neighbours(flash_indices[i,], nrow(octopi), ncol(octopi))
      octopi[nbs][which(octopi[nbs]!=0)] <- octopi[nbs][which(octopi[nbs]!=0)] + 1
    }
    flash_indices <- which(octopi>=10, arr.ind = TRUE)
  }
  return(list('octopi' = octopi, 'flashes' = flashes))
}

fast_forward_energy_levels <- function(octopi, iterations) {
  flashes <- 0
  for (i in 1:iterations) {
    update <- update_energy_levels(octopi)
    octopi <- update$octopi
    flashes <- flashes + update$flashes
  }
  return(list('octopi' = octopi, 'flashes' = flashes))
}

# test input
testthat::expect_equal(fast_forward_energy_levels(test_input, iterations = 100)$flashes, 1656)

# answer
fast_forward_energy_levels(input, iterations = 100)

##### PART TWO #####

find_first_simulatenous_flash <- function(octopi) {
  iteration <- 0
  while (any(octopi!=0)) {
    iteration <- iteration + 1
    octopi <- update_energy_levels(octopi)$octopi
  }
  return(list('octopi' = octopi, 'iteration' = iteration))
}

# test input
testthat::expect_equal(find_first_simulatenous_flash(test_input)$iteration, 195)

# answer
find_first_simulatenous_flash(input)