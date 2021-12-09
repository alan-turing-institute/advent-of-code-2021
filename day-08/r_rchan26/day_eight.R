library(testthat)

read_signals <- function(input) {
  strings <- strsplit(readLines(input), " | ")
  # patterns are the first ten items
  # output values are the last 4 items
  return(list('patterns' = lapply(strings, function(x) x[1:10]),
              'output' = lapply(strings, function(x) x[12:15])))
}

test_input <- read_signals('test_input.txt')
input <- read_signals('input.txt')

##### PART ONE #####

easy_digit_counter <- function(output) {
  # looping through the output and determining how many 1,4,7,8's
  # there are by looking at the length of the strings
  return(sum(sapply(output, function(digits) {
    sapply(digits, function(x) nchar(x) %in% c(2, 3, 4, 7))})))
}

# test input
testthat::expect_equal(easy_digit_counter(test_input$output), 26)

# answer
easy_digit_counter(input$output)

##### PART TWO #####

convert_digit <- function(digit, mapping) {
  digit <- strsplit(digit, "")[[1]]
  if (length(digit)==2) {
    return("1")
  } else if (length(digit)==3) {
    return("7")
  } else if (length(digit)==4) {
    return("4")
  } else if (length(digit)==7) {
    return("8")
  } else {
    converted_digit <- sapply(digit, function(x) unlist(mapping[x]))
    if (all(converted_digit %in% c("a", "b", "c", "e", "f", "g"))) {
      return("0")
    } else if (all(converted_digit %in% c("a", "c", "d", "e", "g"))) {
      return("2")
    } else if (all(converted_digit %in% c("a", "c", "d", "f", "g"))) {
      return("3")
    } else if (all(converted_digit %in% c("a", "b", "d", "f", "g"))) {
      return("5")
    } else if (all(converted_digit %in% c("a", "b", "d", "e", "f", "g"))) {
      return("6")
    } else if (all(converted_digit %in% c("a", "b", "c", "d", "f", "g"))) {
      return("9")
    } else {
      stop("digit cannot be converted with this mapping")
    }
  }
}

reverse_mapping <- function(inverse_mapping) {
  # wrote this function because I realised that I had mapped the wrong way
  # couldn't figure out how to do the reverse quickly, so I just wrote this...
  # meaning that I had the mapping from the true board to the encrypted board
  # I actually need it the other way round to decrypt the board...
  mapping <- lapply(names(inverse_mapping), function(x) x)
  names(mapping) <- inverse_mapping
  return(mapping)
}

decode <- function(input) {
  easy_digits <- lapply(input$patterns, function(x) strsplit(x[which(nchar(x) %in% c(2,3,4,7))], ""))
  six_char_digits <- lapply(input$patterns, function(x) strsplit(x[which(nchar(x)==6)], ""))
  five_char_digits <- lapply(input$patterns, function(x) strsplit(x[which(nchar(x)==5)], ""))
  output_numbers <- rep(NA, length(input$output))
  for (i in 1:length(input$output)) {
    ##### LEARN MAPPING #####
    # create list which maps letters a-g to letters that could be potentially that letter
    # we will remove letters when it is no longer possible that two letters map to each other
    inv_map <- rep(list(c('a', 'b', 'c', 'd', 'e', 'f', 'g')), 7)
    names(inv_map) <- c('a', 'b', 'c', 'd', 'e', 'f', 'g')
    easy_digits[[i]] <- easy_digits[[i]][order(sapply(easy_digits[[i]], length))]
    # use the easy digits to remove some possibilities
    for (digit in easy_digits[[i]]) {
      if (length(digit)==2) {
        # must be 1. update the potential letters for c and f:
        inv_map$c <- intersect(inv_map$c, digit)
        inv_map$f <- inv_map$c
      } else if (length(digit)==3) {
        # must be 7. update the potential letters for a, c and f
        inv_map$a <- intersect(inv_map$a, digit)
        # a cannot be either what is potential for c and f, so we can determine a here
        inv_map$a <- setdiff(inv_map$a, c(inv_map$c, inv_map$f))
      } else if (length(digit)==4) {
        # must be 4. update the potential letters for b, c, d, f
        inv_map$b <- intersect(inv_map$b, digit)
        inv_map$d <- inv_map$b
        # b and d cannot be any of what is potential for c and f
        inv_map$b <- setdiff(inv_map$b, c(inv_map$c, inv_map$f))
        inv_map$d <- inv_map$b
      } else if (length(digit)==7) {
        # must be 8. update potential letters for all letters
        # e and g cannot be any of what is potential for a, b, c, d and f
        inv_map$e <- setdiff(inv_map$e, c(inv_map$a, inv_map$b, inv_map$c, inv_map$d, inv_map$f))
        inv_map$g <- inv_map$e
      }
    }
    # use the digits that are made up of six characters to remove more possibilities
    # compare this with the digit, 4, and want to find 9 
    # (happens if difference in characters is length 2)
    # we know what the inv_map for a is, so we can determine what the inv_map for g
    # (and hence e)
    digit_4 <- easy_digits[[i]][[which(sapply(easy_digits[[1]], length)==4)]]
    for (digit in six_char_digits[[i]]) {
      if (length(setdiff(digit, digit_4))==2) {
        inv_map$g <- setdiff(setdiff(digit, digit_4), inv_map$a)
        inv_map$e <- setdiff(inv_map$e, inv_map$g)
      }
    }
    # use the digits that are made up of five characters to remove more possibilities
    # compare this with three the digit, 7, and want to find 3
    # (happens if difference in characters is length 2)
    # we know what the inv_map for g is, so we can determine what the inv_map for d
    # (and hence b)
    digit_7 <- easy_digits[[i]][[which(sapply(easy_digits[[1]], length)==3)]]
    for (digit in five_char_digits[[i]]) {
      if (length(setdiff(digit, digit_7))==2) {
        inv_map$d <- setdiff(setdiff(digit, digit_7), inv_map$g)
        inv_map$b <- setdiff(inv_map$b, inv_map$d)
      }
    }
    # finally, we have to determine the inv_map for c and f
    # we can determine f since all but one number has f in it. we just check which
    # of the possibilities only occurs in 9 out of 10 numbers
    is_f_in <- sapply(c(easy_digits[[i]],
                        six_char_digits[[i]],
                        five_char_digits[[i]]), function(x) inv_map$f %in% x)
    if (sum(is_f_in[1,])==9) {
      inv_map$f <- inv_map$f[1]
    } else {
      inv_map$f <- inv_map$f[2]
    }
    inv_map$c <- setdiff(inv_map$c, inv_map$f)
    ##### USE MAPPING TO CONVERT NUMBERS #####
    output_digits <- sapply(input$output[[i]], function(x) {
      convert_digit(digit = x, mapping = reverse_mapping(inv_map))})
    # concatenate digits and convert to number
    output_numbers[i] <- as.numeric(paste(output_digits, collapse = ''))
  }
  return(output_numbers)
}

# test input
testthat::expect_equal(sum(decode(test_input)), 61229)

# answer
sum(decode(input))
