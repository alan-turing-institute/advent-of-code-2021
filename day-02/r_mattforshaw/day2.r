## ---------------------------
##
## Script name: Advent of Code 2021 - Day 2
##
## Purpose of script: 
##
## Author: Dr. Matt Forshaw
##
## Date Created: 2021-12-02
##
## Email: mforshaw@turing.ac.uk
##
## ---------------------------
##
## Notes:
##   
##
## ---------------------------

library(tidyverse)

dataset <- read.csv("input.txt", 
                 header=FALSE, 
                 col.names = c("direction","value"), 
                 sep = " ")

## ---------------------------

# Part 1
grouped_results <- dataset %>% 
  group_by(direction) %>% 
  summarise(test = sum(result))

forward <- grouped_results %>% filter(direction == "forward") %>% pull(result)
up <- grouped_results %>% filter(direction == "up") %>% pull(result)
down <- grouped_results %>% filter(direction == "down") %>% pull(result)

final_result <- forward * (down - up)
final_result

## ---------------------------

# Part 2
aim = 0
depth = 0
horizontal_pos = 0
for (i in 1:nrow(dataset))
{
  dir <- dataset[i,]$direction
  val <- dataset[i,]$value
  
  if (dir == "down") {
    aim = aim + val
  }
  if (dir == "up") {
    aim = aim - val
  }
  if (dir == "forward") {
    horizontal_pos = horizontal_pos + val
    depth = depth + aim * val
  }
  print(depth)
}

part2_answer <- horizontal_pos *depth
part2_answer


# Early attempt to use dplyr, but faced challenges in rowwise operations.
# Any feedback on how to approach this would be appreciated.
dataset %>% 
  mutate(horpos = 0,
         aim = 0,
         depth = 0) %>% 
  mutate(aim = case_when(direction == "down" ~ lag(aim, default = 0)+value,
                         direction == "up" ~ lag(aim, default = 0)-value,
                         TRUE ~ lag(aim, default = 0)), 
         horpos = case_when(direction == "forward" ~ lag(horpos,default = 0)+value,
                            TRUE ~ lag(horpos)),
         depth = case_when(direction == "forward" ~ lag(aim, default = 0)*value,
                           TRUE ~ lag(depth, default = 0)))