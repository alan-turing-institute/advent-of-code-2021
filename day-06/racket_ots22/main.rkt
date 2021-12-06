#lang racket

(define (sum xs) (for/sum ([x xs]) x))

(define (counts-to xs n)
  (let ([h (for/hash ([grp (group-by values xs)])
             (values (car grp) (length grp)))])
    (build-vector n (λ (i) (hash-ref h i 0)))))

(define (step istep fish-counts)
  (build-vector 9 (λ (i) (cond
                           [(= i 8) (vector-ref fish-counts 0)]
                           [(= i 6) (+ (vector-ref fish-counts 7)
                                       (vector-ref fish-counts 0))]
                           [else (vector-ref fish-counts (add1 i))]))))

(define (count-fish-on-day day starting-fish)
  (sum (foldl step (counts-to starting-fish 9) (range day))))

(define (part1 starting-fish) (count-fish-on-day 80 starting-fish))
(define (part2 starting-fish) (count-fish-on-day 256 starting-fish))

(define (parse-fish input) (map string->number (string-split input ",")))

(module+ test
  (require rackunit)

  (define test-input "3,4,3,1,2")
  (define starting-fish (parse-fish test-input))

  (check-equal? (part1 starting-fish) 5934)
  (check-equal? (part2 starting-fish) 26984457539))

(module+ main
  (define input (with-input-from-file "6.in" port->string))
  (define starting-fish (parse-fish input))

  (part1 starting-fish)
  (part2 starting-fish))
