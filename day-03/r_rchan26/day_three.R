library(testthat)

##### PART ONE #####

# input data into matrix of strings for each bit
test_input <- do.call(rbind, strsplit(readLines("test_input.txt"), ""))
input <- do.call(rbind, strsplit(readLines("input.txt"), ""))

get_rate <- function(diagnostics) {
  gamma_rate <- apply(diagnostics, 2, function(col) names(sort(table(col), decreasing = TRUE))[1])
  epsilon_rate <- sapply(gamma_rate, function(i) ifelse(i=="0", "1", "0"), USE.NAMES = FALSE)
  return(list('gamma_rate' = paste(gamma_rate, collapse = ""),
              'epsilon_rate' = paste(epsilon_rate, collapse = "")))
}

power_consumption <- function(diagnostics) {
  rates <- get_rate(diagnostics)
  rates_as_decimal <- lapply(rates, function(x) strtoi(x, base = 2))
  return(rates_as_decimal$gamma_rate * rates_as_decimal$epsilon_rate)
}

# test input
testthat::expect_equal(get_rate(test_input)$gamma_rate, "10110")
testthat::expect_equal(get_rate(test_input)$epsilon_rate, "01001")
testthat::expect_equal(strtoi(get_rate(test_input)$gamma_rate, 2), 22)
testthat::expect_equal(strtoi(get_rate(test_input)$epsilon_rate, 2), 9)
testthat::expect_equal(power_consumption(test_input), 198)

# answer
power_consumption(input)

##### PART TWO #####

get_support_rate <- function(diagnostics, rate) {
  data <- diagnostics
  for (j in 1:ncol(diagnostics)) {
    # O2: want to keep highest frequency in column (or 1 if equal)
    # CO2: want to keep lowest frequency in column (or 0 if equal)
    if (rate == "O2") {
      indices <- which(data[,j]=="0")  
    } else if (rate == "CO2") {
      indices <- which(data[,j]=="1")
    } else {
      stop("rate must be \"O2\" or \"CO2\"")
    }
    # look at the sum of the column to determine if there are more zeros or ones
    if (sum(as.integer(data[,j])) < length(data[,j])/2) {
      data <- data[indices,]
    } else {
      data <- data[-indices,]
    }
    if (length(data)==ncol(diagnostics)) {
      break
    }
  }
  return(paste(data, collapse = ""))
}

life_support_rate <- function(diagnostics) {
  O2_rate <- get_support_rate(diagnostics, rate = "O2")
  CO2_rate <- get_support_rate(diagnostics, rate = "CO2")
  return(strtoi(O2_rate, base = 2) * strtoi(CO2_rate, base = 2))
}

# test input
testthat::expect_equal(get_support_rate(test_input, "O2"), "10111")
testthat::expect_equal(get_support_rate(test_input, "CO2"), "01010")
testthat::expect_equal(strtoi(get_support_rate(test_input, "O2"), 2), 23)
testthat::expect_equal(strtoi(get_support_rate(test_input, "CO2"), 2), 10)
testthat::expect_equal(life_support_rate(test_input), 230)

# answer
life_support_rate(input)
