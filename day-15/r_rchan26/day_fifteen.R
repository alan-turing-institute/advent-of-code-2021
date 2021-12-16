library(testthat)

test_input <- do.call(rbind, strsplit(readLines('test_input.txt'), ""))
test_input <- matrix(as.numeric(test_input), nrow = nrow(test_input), ncol = ncol(test_input))
input <- do.call(rbind, strsplit(readLines('input.txt'), ""))
input <- matrix(as.numeric(input), nrow = nrow(input), ncol = ncol(input))

##### PART ONE #####

# used this function 3 times so far during this advent of code
find_neighbours <- function(point, nrows, ncols) {
  neighbours <- matrix(nrow = 4, ncol = 2)
  neighbours[1,] <- c(point[1]-1, point[2])
  neighbours[2,] <- c(point[1]+1, point[2])
  neighbours[3,] <- c(point[1], point[2]-1)
  neighbours[4,] <- c(point[1], point[2]+1)
  return(neighbours[apply(cbind(neighbours >= 1, cbind(neighbours[,1] <= nrows, neighbours[,2] <= ncols)), 1, all),])
}

Dijkstra <- function(start_index, end_index, cave_map) {
  cost <- matrix(Inf, nrow = nrow(cave_map), ncol = ncol(cave_map))
  visited <- matrix(FALSE, nrow = nrow(cave_map), ncol = ncol(cave_map))
  cost[start_index[1], start_index[2]] <- 0
  while (!all(visited)) {
    U <- which(cost==min(cost[!visited]), arr.ind = TRUE)
    for (i in 1:nrow(U)) {
      u <- U[i,]
      if (!visited[u[1], u[2]]) {
        break
      }
    }
    if (all(u == end_index)) {
      return(list('cost' = cost, 'cost_to_end' = cost[end_index[1], end_index[2]]))
    }
    visited[u[1], u[2]] <- TRUE
    neighbours <- find_neighbours(u, nrows = nrow(cave_map), ncols = ncol(cave_map))
    for (i in 1:nrow(neighbours)) {
      v <- neighbours[i,]
      if (!visited[v[1], v[2]]) {
        alt <- cost[u[1], u[2]] + cave_map[v[1], v[2]]
        if (alt < cost[v[1], v[2]]) {
          cost[v[1], v[2]] <- alt
        }
      }
    }
  }
  return(list('cost' = cost, 'cost_to_end' = cost[end_index[1], end_index[2]]))
}

# test input
testthat::expect_equal(Dijkstra(start_index = c(1,1),
                                end_index = c(nrow(test_input), ncol(test_input)),
                                cave_map = test_input)$cost_to_end,
                       40)

# answer
ptm <- proc.time()
Dijkstra(start_index = c(1,1),
         end_index = c(nrow(input), ncol(input)),
         cave_map = input)$cost_to_end
print(paste('time_elapsed:',(proc.time()-ptm)['elapsed']))

# microbenchmark::microbenchmark(Dijkstra(start_index = c(1,1),
#                                         end_index = c(nrow(input), ncol(input)),
#                                         cave_map = input)$cost_to_end)

##### PART TWO #####

expand_cave <- function(cave_map) {
  expansion <- matrix(nrow = 5*nrow(cave_map), ncol = 5*nrow(cave_map))
  for (i in 1:5) {
    i_fill <- 1:nrow(cave_map) + (i-1)*nrow(cave_map)
    for (j in 1:5) {
      j_fill <- 1:ncol(cave_map) + (j-1)*ncol(cave_map)
      expansion[i_fill,j_fill] <- ((i+j-2)+cave_map) %% 9
      expansion[i_fill,j_fill][expansion[i_fill,j_fill]==0] <- 9
    }
  }
  return(expansion)
}

test_input_expanded <- expand_cave(test_input)
input_expanded <- expand_cave(input)

# test input
testthat::expect_equal(Dijkstra(start_index = c(1,1),
                                end_index = c(nrow(test_input_expanded), ncol(test_input_expanded)),
                                cave_map = test_input_expanded)$cost_to_end,
                       315)

# answer
ptm <- proc.time()
Dijkstra(start_index = c(1,1),
         end_index = c(nrow(input_expanded), ncol(input_expanded)),
         cave_map = input_expanded)$cost_to_end
print(paste('time_elapsed:',(proc.time()-ptm)['elapsed']))
