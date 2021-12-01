##### PART ONE #####

test_input <- read.csv(file = "test_input.txt", header = FALSE, col.names = "depth")
input <- read.csv("input.txt", header = FALSE, col.names = "depth")

count_increasing <- function(df) {
  return(sum((df[2:nrow(df),]-df[1:(nrow(df)-1),])>0))
}

count_increasing(test_input) # 7
count_increasing(input)

##### PART TWO #####

sliding_window_sum <- function(df) {
  return(as.matrix(sapply(1:(nrow(df)-2), function(i) sum(df[i:(i+2),]))))
}

count_increasing(sliding_window_sum(test_input)) # 5
count_increasing(sliding_window_sum(input))
