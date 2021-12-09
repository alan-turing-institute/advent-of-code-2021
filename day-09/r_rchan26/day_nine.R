library(testthat)

test_input <- do.call(rbind, strsplit(readLines('test_input.txt'), ""))
test_input <- matrix(as.numeric(test_input), nrow = nrow(test_input), ncol = ncol(test_input))
input <- do.call(rbind, strsplit(readLines('input.txt'), ""))
input <- matrix(as.numeric(input), nrow = nrow(input), ncol = ncol(input))

##### PART ONE #####

find_low_point_in_vector <- function(vector) {
  return(vector < lag(vector, default = Inf) & vector < lead(vector, default = Inf))
}

find_low_points <- function(heightmap) {
  # find any low points along the rows
  rows <- t(apply(heightmap, 1, find_low_point_in_vector))
  # find any low points along the columns
  columns <- apply(heightmap, 2, find_low_point_in_vector)
  return(list('locations' = which(rows&columns, arr.ind = TRUE),
              'values' = heightmap[rows & columns]))
}

compute_risk_level <- function(heightmap) {
  return(sum(find_low_points(heightmap)$values + 1))
}

# test input
testthat::expect_equal(compute_risk_level(test_input), 15)

# answer
compute_risk_level(input)

##### PART TWO #####

find_basin_borders <- function(heightmap) {
  # find where the 9s occur since they create the boarders for the basins
  rows <- t(apply(heightmap, 1, function(vector) vector==9))
  columns <- apply(heightmap, 2, function(vector) vector==9)
  return(list('matrix' = rows&columns,
              'locations' = which(rows&columns, arr.ind = TRUE)))
}

find_neighbours <- function(point, nrows, ncols) {
  neighbours <- matrix(nrow = 4, ncol = 2)
  neighbours[1,] <- c(point[1]-1, point[2])
  neighbours[2,] <- c(point[1]+1, point[2])
  neighbours[3,] <- c(point[1], point[2]-1)
  neighbours[4,] <- c(point[1], point[2]+1)
  return(neighbours[apply(cbind(neighbours >= 1, cbind(neighbours[,1] <= nrows, neighbours[,2] <= ncols)), 1, all),])
}

compute_basin_size <- function(start_point, basin_borders_matrix) {
  if (start_point[1] < 1 | start_point[1] > nrow(basin_borders_matrix)) {
    stop("start_point outside the matrix")
  } else if (start_point[2] < 1 | start_point[2] > ncol(basin_borders_matrix)) {
    stop("start_point outside the matrix")
  } else if (basin_borders_matrix[start_point[1], start_point[2]]) {
    stop("start_point is on a border")
  }
  basin_member_locations <- matrix(NA, nrow = length(basin_borders_matrix), ncol = 2)
  row_index <- 1
  # first want to check the start point and the neighbours
  to_check <- rbind(start_point,
                    find_neighbours(start_point,
                                    nrow(basin_borders_matrix),
                                    ncol(basin_borders_matrix)))
  # remove any that are currently TRUE in the basin_borders_matrix,
  # since these are borders and don't contribute to the count
  to_check <- to_check[!basin_borders_matrix[to_check],,drop=FALSE]
  while (nrow(to_check) >= 1) {
    for (i in 1:nrow(to_check)) {
      if (!basin_borders_matrix[to_check[i,1], to_check[i,2]]) {
        basin_borders_matrix[to_check[i,1], to_check[i,2]] <- TRUE
        basin_member_locations[row_index,] <- to_check[i,]
        row_index <- row_index+1
      }
    }
    # want to check all the neighbours for each point in to_check
    to_check <- do.call(rbind, lapply(1:nrow(to_check), function(i) {
      find_neighbours(to_check[i,], nrow(basin_borders_matrix), ncol(basin_borders_matrix))}))
    # remove duplicates
    to_check <- unique(to_check)
    # remove any that are currently TRUE, since these are borders
    # OR they have already been checked and added to the basin_member_locations
    # and don't contribute any further to the count anymore
    to_check <- to_check[!basin_borders_matrix[to_check],,drop=FALSE]
  }
  basin_member_locations <- basin_member_locations[complete.cases(basin_member_locations),,drop=FALSE]
  return(list('size' = nrow(basin_member_locations),
              'locations' = basin_member_locations))
}

part_two <- function(heightmap) {
  # find the low points in the heightmap
  low_points <- find_low_points(heightmap)$locations
  # find where the borders of each basin are
  basin_borders_matrix <- find_basin_borders(heightmap)$matrix
  # each low point has a basin, so for each low point, compute the basin size
  basin_sizes <- sapply(1:nrow(low_points), function(i) {
    compute_basin_size(low_points[i,], basin_borders_matrix)$size
  })
  # multiply the top 3 sizes
  return(prod(sort(basin_sizes, decreasing = TRUE)[1:3]))
}

# test input
testthat::expect_equal(part_two(test_input), 1134)

# answer
part_two(input)
