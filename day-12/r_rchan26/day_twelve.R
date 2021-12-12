library(testthat)

# creates a list called map, where map[[position]] returns the possible next
# destinations from 'position' (i.e. caves accessible in one step from 'position')
obtain_cave_mapping <- function(input) {
  map <- list()
  for (l in readLines(input)) {
    edge <- strsplit(l, "-")[[1]]
    map[[edge[1]]] <- c(map[[edge[1]]], edge[[2]])
    map[[edge[2]]] <- c(map[[edge[2]]], edge[[1]])
  }
  return(map)
}

test_input_1 <- obtain_cave_mapping("test_input_1.txt")
test_input_2 <- obtain_cave_mapping("test_input_2.txt")
test_input_3 <- obtain_cave_mapping("test_input_3.txt")
input <- obtain_cave_mapping("input.txt")

##### PART ONE #####

# recursive call to continue each path until reach end or invalid path
continue_path <- function(cave, cave_mapping, visited) {
  if (cave == "end") {
    return(1)
  }
  if (cave == tolower(cave)) {
    if (!visited[[cave]]) {
      visited[[cave]] <- TRUE
    } else {
      return(0)
    }
  }
  n <- 0
  for (destination in cave_mapping[[cave]]) {
    n <- n + continue_path(cave = destination,
                           cave_mapping = cave_mapping,
                           visited = visited)
  }
  return(n)
}

count_number_of_paths <- function(cave_mapping) {
  low_case_caves <- names(cave_mapping)[names(cave_mapping)==tolower(names(cave_mapping))]
  visited <- rep(FALSE, length(low_case_caves))
  names(visited) <- low_case_caves
  return(continue_path(cave = "start",
                       cave_mapping = cave_mapping,
                       visited = visited))
}

# test inputs
testthat::expect_equal(count_number_of_paths(test_input_1), 10)
testthat::expect_equal(count_number_of_paths(test_input_2), 19)
testthat::expect_equal(count_number_of_paths(test_input_3), 226)

# answer
count_number_of_paths(input)

##### PART TWO #####

# amending PART ONE solution slightly
# have another variable small_twice_visit to indicate if a small cave (which is not "start")
# is visited twice. this allows only one small cave to be visited twice
continue_path_v2 <- function(cave, cave_mapping, visited, small_twice_visit) {
  if (cave == "end") {
    return(1)
  }
  if (cave == tolower(cave)) {
    if (!visited[[cave]]) {
      visited[[cave]] <- TRUE
    } else {
      if (!small_twice_visit & cave!="start") {
        small_twice_visit <- TRUE
      } else {
        return(0)
      }
    }
  }
  n <- 0
  for (destination in cave_mapping[[cave]]) {
    n <- n + continue_path_v2(cave = destination,
                              cave_mapping = cave_mapping,
                              visited = visited,
                              small_twice_visit = small_twice_visit)
  }
  return(n)
}

count_number_of_paths_v2 <- function(cave_mapping) {
  low_case_caves <- names(cave_mapping)[names(cave_mapping)==tolower(names(cave_mapping))]
  visited <- rep(FALSE, length(low_case_caves))
  names(visited) <- low_case_caves
  return(continue_path_v2(cave = "start",
                          cave_mapping = cave_mapping,
                          visited = visited,
                          small_twice_visit = FALSE))
}

# test inputs
testthat::expect_equal(count_number_of_paths_v2(test_input_1), 36)
testthat::expect_equal(count_number_of_paths_v2(test_input_2), 103)
testthat::expect_equal(count_number_of_paths_v2(test_input_3), 3509)

# answer
count_number_of_paths_v2(input)
