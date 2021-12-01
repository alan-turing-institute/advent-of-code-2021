## ---------------------------
##
## Script name: Advent of Code 2021 - Day 1
##
## Purpose of script: 
##
## Author: Dr. Matt Forshaw
##
## Date Created: 2021-12-01
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
library(RcppRoll) # Import RccpRoll for roll_sum

sonar <- read_csv("input.txt",
                  col_names = "depth")

sonar <- read_csv("test_input.txt",
              col_names = "depth")

## ---------------------------

# Part 1
p1 <- sonar %>% 
  mutate(increased = depth > lag(depth)) %>% 
  group_by(increased) %>% count()
  
answer1 <- p1 %>% filter(increased == TRUE) %>% pull(n)
answer1
## ---------------------------

# Part 2
p2 <- sonar %>% 
  mutate(increased = depth > lag(depth),  
         rollsum = roll_sum(depth, 3, align = "right", fill = NA),
         rollsum_increased = rollsum > lag(rollsum)) %>% 
  group_by(rollsum_increased) %>% count()

answer2 <- p2 %>% 
  filter(rollsum_increased == TRUE) %>% pull(n)
answer2
