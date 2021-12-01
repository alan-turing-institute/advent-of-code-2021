#lang racket

; my first racket program!

(require 2htdp/batch-io)

(define INPATH "./input_1.txt")

;; PART ONE

; read the file to a list of strings and map to number
(define l (map string->number (read-lines INPATH)))

; function to compare list to itself shifted by one, is next item larger (assumes true for first element)
; increases: list -> list
(define (increases number-list)
  (define len (length number-list))
  ; ignore last element of first list
  ; ignore first element of second list
  (map >
       (rest number-list)
       (take number-list (- len 1)))) ; this is O(N) :(

; count #t instances
(define answer-1 (count identity (increases l)))


;; PART TWO - uses l from part one

; need sliding window of size 3 over l

; create a new list, window-sums
; loop through a range of size list - 3 (so we don't go past end of list with window)
(define window-sums (for/list ([i (- (length l) 2)])
    ; sum sliding window of size 3 starting at index i                  
    (apply +
           (take (list-tail l i) 3)) ; list-tail is same as drop - this is O(N)
  )
  )
(define answer-2 (count identity (increases window-sums)))

(display "########\n\n")
(display "part one answer: ")
(display answer-1)
(display "\n\n########\n\n")
(display "part two answer: ")
(display answer-2)
(display "\n\n########")