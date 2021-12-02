#lang racket

(require 2htdp/batch-io)

(define INPATH "./input_2.txt")


; read the file, auto parsing to list of lists and converting numerics
(define command-list (read-words-and-numbers/line INPATH))

; part one
; use a cond to figure out what to accumulate
(define (accumulate-per-direction cmd-list)
  (for/fold ([h 0]
             [v 0])
            ([cmd cmd-list])

  (define direction (first cmd))
  (define value (second cmd))
    
  (cond
    [(string=? "forward" direction) (values (+ h value) v)]
    [(string=? "up" direction) (values  h (- v value))]
    [(string=? "down" direction) (values h (+ v value))])
    
    )
)

; part two
; very similar to part one but now involes "aim"
(define (accumulate-with-aim cmd-list)
  (for/fold ([h 0]
             [v 0]
             [aim 0])
            ([cmd cmd-list])

  (define direction (first cmd))
  (define value (second cmd))

    
  (cond
    [(string=? "forward" direction) (values (+ h value) ( + v (* value aim)) aim)]
    [(string=? "up" direction) (values  h v (- aim value))]
    [(string=? "down" direction) (values h v (+ aim value))])
    
    )

)

(define-values (horizontal vertical) (accumulate-per-direction command-list))

(display "ANSWER 1\n")
(* horizontal vertical)
(display "\n####\n\n")

(define-values (horizontal2 vertical2 aim2) (accumulate-with-aim command-list))

(display "ANSWER 2\n")
(* horizontal2 vertical2)


