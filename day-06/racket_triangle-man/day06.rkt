#lang racket/base

(require racket/string)

(define (collate-timers list-of-fish new-fish-timer)
  (let ([fishes (make-vector (+ new-fish-timer 1) 0)])
    (for ([timer (in-list list-of-fish)])
      (vector-set! fishes timer (+ (vector-ref fishes timer) 1)))
    fishes))

(define (tick ages new-fish-timer after-spawn-timer)
  (let ([new-ages (make-vector (+ new-fish-timer 1) 0)])
    (for ([age new-fish-timer])
      (vector-set! new-ages age
                   (vector-ref ages (+ age 1))))
    (vector-set! new-ages new-fish-timer
                 (vector-ref ages 0))
    (vector-set! new-ages after-spawn-timer
                 (+ (vector-ref new-ages after-spawn-timer)
                    (vector-ref ages 0)))
    new-ages))

(define (run ages new-fish-timer after-spawn-timer N)
  (for/fold ([ages ages])
            ([_ N])
    (tick ages new-fish-timer after-spawn-timer)))


;; ----------------------------------------------------------------------

(module+ test
  (require rackunit)

  (define *input* '(3 4 3 1 2))
  (define *fishes* (collate-timers *input* 8))

  (check-equal? 5934 (apply + (vector->list (run *fishes* 8 6 80))))
  (check-equal? 26984457539 (apply + (vector->list (run *fishes* 8 6 256))))

  )

;; ----------------------------------------------------------------------

(module+ main
  (define *input* (map string->number (string-split
                                       "1,1,5,2,1,1,5,5,3,1,1,1,1,1,1,3,4,5,2,1,2,1,1,1,1,1,1,1,1,3,1,1,5,4,5,1,5,3,1,3,2,1,1,1,1,2,4,1,5,1,1,1,4,4,1,1,1,1,1,1,3,4,5,1,1,2,1,1,5,1,1,4,1,4,4,2,4,4,2,2,1,2,3,1,1,2,5,3,1,1,1,4,1,2,2,1,4,1,1,2,5,1,3,2,5,2,5,1,1,1,5,3,1,3,1,5,3,3,4,1,1,4,4,1,3,3,2,5,5,1,1,1,1,3,1,5,2,1,3,5,1,4,3,1,3,1,1,3,1,1,1,1,1,1,5,1,1,5,5,2,1,5,1,4,1,1,5,1,1,1,5,5,5,1,4,5,1,3,1,2,5,1,1,1,5,1,1,4,1,1,2,3,1,3,4,1,2,1,4,3,1,2,4,1,5,1,1,1,1,1,3,4,1,1,5,1,1,3,1,1,2,1,3,1,2,1,1,3,3,4,5,3,5,1,1,1,1,1,1,1,1,1,5,4,1,5,1,3,1,1,2,5,1,1,4,1,1,4,4,3,1,2,1,2,4,4,4,1,2,1,3,2,4,4,1,1,1,1,4,1,1,1,1,1,4,1,5,4,1,5,4,1,1,2,5,5,1,1,1,5"
                                       ",")))

  (define *fishes* (collate-timers *input* 8))

  ;; Part one
  (apply + (vector->list (run *fishes* 8 6 80)))

  ;; Part two
  (apply + (vector->list (run *fishes* 8 6 256)))
  )
