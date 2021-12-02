#lang racket/base

(require racket/string
         racket/match
         racket/port)


;; Type definitions
;; ----------------

;; A submarine is an x-coord, a depth, and an aim
(struct submarine (x depth aim) #:transparent)

(define (aim sub δaim)
  (struct-copy submarine sub
               [aim (+ (submarine-aim sub) δaim)]))

(define (move sub δ)
  (struct-copy submarine sub
               [x     (+ (submarine-x sub)  δ)]
               [depth (+ (submarine-depth sub) (* δ (submarine-aim sub)))]))

;; A command is a direction and a displacement
;; A direction is one of 'up, 'down, or 'forward
(struct command (dir displ) #:transparent)


;; Parsing the input
;; -----------------

;; port? -> [List-of command?] 
(define (parse-course port)
  (map parse-command
       (port->lines port)))

;; string? -> command?
(define (parse-command str)
  (match (string-split str)
    [`("up" ,δ)      (command 'up (string->number δ))]
    [`("down" ,δ)    (command 'down (string->number δ))]
    [`("forward" ,δ) (command 'forward (string->number δ))]))


;; Following courses
;; -----------------

;; location? command? -> location?
(define (execute com sub)
  (match com
    [(command 'up δ)      (aim sub (- δ))]
    [(command 'down δ)    (aim sub δ)]
    [(command 'forward δ) (move sub δ)]))

;; location? course? -> location?
(define (follow-course start cs)
  (for/fold ([sub start])
            ([com cs])
    (execute com sub)))


;; Part one
(define (part-two course)
  (let ([final-sub (follow-course (submarine 0 0 0) course)])
    (* (submarine-x final-sub) (submarine-depth final-sub))))


;; ----------------------------------------------------------------------

(module+ main
  (define *course*
    (call-with-input-file "input.txt" parse-course))

  (part-two *course*))



;; ----------------------------------------------------------------------

(module+ test
  (require rackunit)
  (define *test-input* #<<EOS
forward 5
down 5
forward 8
up 3
down 8
forward 2
EOS
    )
  
  (define *course*
    (call-with-input-string *test-input* parse-course))
  
  (check-equal?
   (part-two *course*)
   900
   "Part two"))
