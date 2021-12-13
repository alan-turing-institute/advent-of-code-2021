library(testthat)

parse_manual <- function(input) {
  lines <- readLines(input)
  dots <- lapply(lines[1:(which(lines=="")-1)], function(x) as.numeric(strsplit(x, ",")[[1]]))
  dots <- do.call(rbind, dots)
  folds <- lapply(lines[(which(lines=="")+1):length(lines)], function(x) strsplit(x, " ")[[1]][3])
  folds <- lapply(folds, function(x) strsplit(x, "=")[[1]])
  return(list('dots' = dots, 'folds' = folds))
}

test_input <- parse_manual("test_input.txt")
input <- parse_manual("input.txt")

obtain_grid <- function(dots) {
  # (x,y) means x column, y row here, but in R, [x,y] gives x row, y column so we swap order
  dots <- cbind(dots[,2], dots[,1])
  grid <- matrix(data = 0, nrow = max(dots[,1])+1, ncol = max(dots[,2]+1))
  grid[dots+1] <- 1
  return(grid)
}

##### PART ONE #####

fold <- function(grid, fold_instruction) {
  if (fold_instruction[1] == "y") {
    horizontal <- TRUE
  } else {
    horizontal <- FALSE
  }
  location <- as.numeric(fold_instruction[2])+1
  if (horizontal) {
    above <- grid[1:(location),]
    below <- grid[(location):nrow(grid),]
    above <- above + below[1:nrow(above),][rev(1:nrow(below[1:nrow(above),])),]
    above[which(above>1)] <- 1
    return(above)
  } else {
    left <- grid[,1:(location)]
    right <- grid[,(location):ncol(grid)]
    left <- left + right[,1:ncol(left)][,rev(1:ncol(right[,1:ncol(left)]))]
    left[which(left>1)] <- 1
    return(left)
  }
}

part_one <- function(input) {
  return(sum(fold(obtain_grid(input$dots), input$folds[[1]])))
}

# test input
testthat::expect_equal(part_one(test_input), 17)

# answer
part_one(input)

##### PART TWO #####

part_two <- function(input) {
  grid <- obtain_grid(input$dots)
  for (instruction in input$folds) {
    grid <- fold(grid, instruction)
  }
  return(grid)
}

# test input (should give a square)
part_two(test_input)

# answer
part_two(input)
