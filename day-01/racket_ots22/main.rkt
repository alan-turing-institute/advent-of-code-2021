#lang racket/base

(require racket/sequence)

;; Part 1

(define (count-increasing data)
  (sequence-count < (in-parallel data (sequence-tail data 1))))

(module+ test
  (require rackunit)

  (define test-data '(199 200 208 210 200 207 240 269 260 263))
  (check-equal? (count-increasing test-data) 7))

(module+ main
  (require racket/port)

  (define input (map string->number
                     (with-input-from-file "1.in" port->lines)))

  (printf "Part 1: ~a~%" (count-increasing input)))

;; Part 2

(define (in-windowed seq n)
  (for/fold ([tails (list seq)]
             #:result (apply in-parallel (reverse tails)))
            ([i (sub1 n)])
    (cons (sequence-tail (car tails) 1) tails)))

(define (count-increasing-window data)
  (count-increasing (sequence-map + (in-windowed data 3))))

(module+ test
  (check-equal? (count-increasing-window test-data) 5))

(module+ main
  (printf "Part 2: ~a~%" (count-increasing-window input)))
