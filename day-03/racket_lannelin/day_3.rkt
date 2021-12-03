#lang racket


; ran out of time with this and have a very messy part two without early exit! (and a messy part one to be honest...)


; PART ONE

; given multiline input of arbitrary length, each line is a binary number of abitrary length (consistent throughout file)
; gamma rate can be determined by finding the most common bit in the corresponding position of all numbers in the diagnostic report


(define (literal-number->char x)
  (integer->char (+ x 48))
  )


(define (char->literal-number x)
  (- (char->integer x) 48)
  )

; convert list of strings to list of list of numbers
; e.g ("0110" "0010") -> ((0 1 1 0) (0 0 1 0))
(define (prepare-reports str-list)
  (map (lambda (x) (map char->literal-number (string->list x))) str-list)
  )


(define (rate-as-int-list sums threshold comparison-fn)
  ; compare each item in list to threshold
  (define compared (map (lambda (x) (comparison-fn x threshold)) sums))
  ; to int
  (map (lambda (x) (or (and x 1) 0)) compared)
  )


(define (binary-int-list->binary-number int-list) 
  ; to single string
  (define result-string (list->string (map literal-number->char int-list)))

  ; convert to binary
  (string->number (string-append "#b" result-string))
  )


; separated out as useful to return as list for part-two
; get most and least common bits per position from a list of lists of numbers representing binary
; e.g ((0 1 1 0) (0 0 1 0))
(define (get-most-least-common num-list)
  
  ; note the threshold for most-common, based on length of num list
  ; could exit summation early based on this (future ext)
  (define threshold (/ (length num-list) 2))

  ; get sum per bit position (element in sublist)
  (define position-sums (apply map + num-list))

  (define most-common (rate-as-int-list position-sums threshold >=))
  ; note could have inverted above
  (define least-common (rate-as-int-list position-sums threshold <))

  (cons most-common least-common)
  )



(define (part-one str-list)
  (define num-list (prepare-reports str-list))
  (define most-least-common (get-most-least-common num-list))

  (define gamma (binary-int-list->binary-number (car most-least-common)))
  (define epsilon (binary-int-list->binary-number (cdr most-least-common)))
  ; return multiplication
  (* gamma epsilon)
  )

; PART TWO


(define (messy-life-support-rating-fn num-list comparator_fn)

  (for/fold ([current-lists num-list]
             [binstr "#b"])
            ([z (length (first num-list))])


    ;#:final (equal? (length current-lists) 1) ; abaondoned early exit code

   
    ; length of current set of lists
    (define l (length current-lists))
    ; threshold will be half this
    (define threshold (/ l 2))
    ; sum of first item in each list
    (define first-sum (apply + (map first current-lists)))
    ; commpare this to threshold
    (define compared (comparator_fn  first-sum threshold))
    ; cast from bool
    ; cheat here and override this if length is 1
    (define v
      (if (equal? (length current-lists) 1)
          (first (first current-lists))
          (or (and compared 1) 0)))

    
    ; filter lists to only include those that start with most common

    (define filtered (filter (lambda (x) (equal? v (first x))) current-lists))
    (values (map rest filtered) (string-append binstr (number->string v)))
    
  
    ))

(define (part-two str-list)
  (define num-list (prepare-reports str-list))
  (define-values (ignore oxy) (messy-life-support-rating-fn num-list >=))

  (define-values (ignore2 co2) (messy-life-support-rating-fn num-list <))

  (* (string->number oxy) (string->number co2))
  )

; --------- MAIN ---------

(module+ main
  
  (require 2htdp/batch-io)
  
  
  (define inlines (read-lines "input_3.txt"))

  (define answer-one (part-one inlines))
  (display "answer 1\n")
  (display answer-one)

  (define answer-two (part-two inlines))
  (display "\n\n###\n\nanswer 2\n")
  (display answer-two)
  
  )

; --------- TEST ---------

(module+ test
  (require rackunit)

  (define testin '(
                   "00100"
                   "11110"
                   "10110"
                   "10111"
                   "10101"
                   "01111"
                   "00111"
                   "11100"
                   "10000"
                   "11001"
                   "00010"
                   "01010"))

  (check-equal? (part-one testin) 198 "Part one test")
  (check-equal? (part-two testin) 230 "Part two test")
  )







