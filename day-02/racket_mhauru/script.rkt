#lang racket
(define lines (map string-split (file->lines "input")))

; Part 1
(define (filter-command cmd lines)
  (map
    (lambda (s) (string->number (first (rest s))))
    (filter
      (lambda (pair) (equal? (first pair) cmd))
      lines)))
(define ups (filter-command "up" lines))
(define downs (filter-command "down" lines))
(define forwards (filter-command "forward" lines))
(display (* (- (apply + downs) (apply + ups)) (apply + forwards)))
(display "\n")

; Part 2
(struct substate (x y aim) #:transparent)

(define (substate-up state amount)
  (define new-aim (- (substate-aim state) amount))
  (struct-copy substate state [aim new-aim]))

(define (substate-down state amount)
  (define new-aim (+ (substate-aim state) amount))
  (struct-copy substate state [aim new-aim]))

(define (substate-forward state amount)
  (define new-x (+ (substate-x state) amount))
  (define new-y (+ (substate-y state) (* amount (substate-aim state))))
  (struct-copy substate state [y new-y] [x new-x]))

(define (result state) (* (substate-x state) (substate-y state)))

(define (update-substate state line)
  (match-define (list cmd amount) line)
  (set! amount (string->number amount))
  (cond
    [(equal? cmd "up") (substate-up state amount)]
    [(equal? cmd "down") (substate-down state amount)]
    [else  (substate-forward state amount)]))

(define state (for/fold
                ([state (substate 0 0 0)])
                ([line lines])
                (update-substate state line)))

(display (result state))
