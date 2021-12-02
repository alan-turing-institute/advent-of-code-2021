#lang racket

(module+ test
  (require rackunit)
  (define test-input
    '("forward 5" "down 5" "forward 8" "up 3" "down 8" "forward 2")))

(define (parse-cmd line)
  (match-define (list dirn-str mag-str) (string-split line))
  (list (case dirn-str
          [("down") 'down]
          [("up") 'up]
          [("forward") 'forward]
          [else (raise-arguments-error 'parse-cmd "Unknown direction"
                                       "dirn-str" dirn-str)])
        (string->number mag-str)))

(define (part1 input)
  (for/fold ([h 0]
             [d 0]
             #:result (* h d))
            ([cmd (map parse-cmd input)])
    (match cmd
      [(list 'down x) (values h (+ d x))]
      [(list 'up x) (values h (- d x))]
      [(list 'forward x) (values (+ h x) d)])))

(module+ test
  (check-equal? (part1 test-input) 150))

(module+ main
  (define input (with-input-from-file "2.in" port->lines))
  (part1 input))

(define (part2 input)
  (for/fold ([h 0]
             [d 0]
             [aim 0]
             #:result (* h d))
            ([cmd (map parse-cmd input)])
    (match cmd
      [(list 'down x) (values h d (+ aim x))]
      [(list 'up x) (values h d (- aim x))]
      [(list 'forward x) (values (+ h x) (+ d (* aim x)) aim)])))

(module+ test
  (check-equal? (part2 test-input) 900))

(module+ main
  (part2 input))
