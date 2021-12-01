#lang racket/base

(require racket/list
         racket/function)


;; Return a list of succesive overlapping sequences of n elements from xs
;; The library function `take` raises an exception if there are insufficient values remaining
(define (take-by xs n)
  (let ([next-n
         (with-handlers ([exn:fail:contract? (λ (e) #f)])
           (take xs n))])
    (if next-n
        (cons next-n (take-by (cdr xs) n))
        null)))

(define (part-one ns)
  (count
   (λ (xs) (apply < xs))
   (take-by ns 2)))

(define (part-two ns)
  (part-one (map (curry apply +) (take-by ns 3))))


;; Alternative approach to part one
(define (part-one-alt ns)
  (for/sum ([i   ns]
            [i+1 (cdr ns)]
            #:when (< i i+1))
    1))


;; ----------------------------------------------------------------------

(module+ main
  (require racket/port)
  
  (define *input*
    (map string->number
         (with-input-from-file "input.txt" port->lines)))

  (part-one *input*)
  (part-two *input*)
  )


;; ----------------------------------------------------------------------

(module+ test
  (require rackunit)
  (define *test* '(199
                   200
                   208
                   210
                   200
                   207
                   240
                   269
                   260
                   263))
  (check-equal? (part-one *test*) 7 "Part one test")
  (check-equal? (part-two *test*) 5 "Part two test")

  )
