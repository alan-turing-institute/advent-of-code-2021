#lang racket/base

(require math/statistics)
(require racket/string)
(require racket/function)

(module+ test
  (require rackunit)
  (define *input*
    (map string->number (string-split "16,1,2,0,4,2,7,1,2,14" ",")))

  (check-equal?  37 (minimum-fuel/1 *input*))
  (check-equal? 168 (minimum-fuel/2 *input*))

  )

(module+ main
  (define *input*
    (with-input-from-file "input.txt"
      (thunk (map string->number (string-split (read-line) ",")))))

  ;; Part one
  (minimum-fuel/1 *input*)

  ;; Part two (something of a cheat)
  (minimum-fuel/2 *input*)

  )


;; ----------------------------------------------------------------------

(define (minimum-fuel/1 posns)
  (let ([m (median < posns)])
    (for/sum ([p posns])
      (abs (- p m)))))

(define (minimum-fuel/2 posns)
  (let ([m (mean posns)])
    ;; I mean, it's *probably* one of these two ... 
    (min (required-fuel/2 (floor m) posns)
         (required-fuel/2 (ceiling m) posns))))

(define (required-fuel/2 x posns)
    (for/sum ([p posns])
      (sum-1-to-n (abs (- p x)))))

(define (sum-1-to-n n)
  (/ (* n (+ n 1)) 2))
