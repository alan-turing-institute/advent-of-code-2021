#lang racket

; late (night) submission for day 7
; gave up (fairly easily) and did brute force for part 2

(require math/statistics)


(define (triangle x)
  (/  (* x (+ x 1)) 2))

(define (parse-input input-str)
  ; split on comma and map to number
  (map string->number (string-split input-str ",")))

(define (part-one str-list)
  (let ([l (parse-input str-list)])
    (apply + (map (λ (x) (abs (- x (median < l)))) l))))

(define (part-two str-list)
  ; brute force solution: calc dist for each possible i value, floor to ceil
  (let ([l (parse-input str-list)])
    (argmin identity
            (for/list ([i (in-range (apply min l) (apply max l))])
              (apply + (map (λ (x) (triangle (abs (- x i)))) l))))))

; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_7.txt"))
  
  (define answer-one (part-one instr))
  (display "answer 1\n")
  (display answer-one);

  (define answer-two (part-two instr))
  (display "\n\n###\n\nanswer 2\n")
  (display answer-two)
  
  )


; --------- TEST ---------

(module+ test
  (require rackunit)

  (define testin "16,1,2,0,4,2,7,1,2,14")

  (check-equal? (part-one testin) 37 "Part one test")
  
  (check-equal? (part-two testin) 168 "Part two test")
  )
