#lang racket/base

(require racket/string
         racket/match
         racket/port)


;; Type definitions
;; ----------------

;; A location is an x-coord and a depth
(struct location (x depth) #:transparent)

(define (location-displace loc δx δd)
  (location (+ δx (location-x loc)) (+ δd (location-depth loc))))

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
(define (execute com loc)
  (match com
    [(command 'up δ)      (location-displace loc 0 (- δ))]
    [(command 'down δ)    (location-displace loc 0 δ)]
    [(command 'forward δ) (location-displace loc δ 0)]))

;; location? course? -> location?
(define (follow-course start cs)
  (for/fold ([loc start])
            ([com cs])
    (execute com loc)))


;; Part one
(define (part-one course)
  (let ([final-loc (follow-course (location 0 0) course)])
    (* (location-x final-loc) (location-depth final-loc))))


;; ----------------------------------------------------------------------

(module+ main
  (define *course*
    (call-with-input-file "input.txt" parse-course))

  (part-one *course*))



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
   (part-one *course*)
   150
   "Part one"))
