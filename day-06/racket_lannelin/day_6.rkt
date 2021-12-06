#lang racket


(define (parse-input input-str)
  ; split on comma and map to number
  (map string->number (string-split input-str ",")))


; shifts vector 1 position left, wrapping
(define (vector-shiftl vec)
  (vector-append (vector-drop vec 1) (vector-take vec 1)))
          

(define (spawning-sim input-str t)
  ; construct initial counts
  (define initial-counts (for/fold ([counts (make-vector 9)])
                                   ([x (parse-input input-str)])
                           (vector-set! counts x (add1 (vector-ref counts x)))
                           (identity counts)
  
                           ))

  ; iterate, updating counts per time step
  (define end-counts (for/fold ([counts initial-counts])
                               ([i t])
                       ; set to pre-shift location (i.e. 7)
                       ; allow wrap around of shift to "spawn"
                       (vector-set! counts 7 (+ (vector-ref counts 7) (vector-ref counts 0)))
                       
                       (vector-shiftl counts)))

  ; return sum of counts for each position
  (apply + (vector->list end-counts)))



(define (part-one input-str)
  (spawning-sim input-str 80))

(define (part-two input-str)
  (spawning-sim input-str 256))
  

                        

; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_6.txt"))
  
  (define answer-one (part-one instr))
  (display "answer 1\n")
  (display answer-one)

  (define answer-two (part-two instr))
  (display "\n\n###\n\nanswer 2\n")
  (display answer-two)
  
  )


; --------- TEST ---------

(module+ test
  (require rackunit)

  (define testin "3,4,3,1,2")

  (check-equal? (part-one testin) 5934 "Part one test")
  
  (check-equal? (part-two testin) 26984457539 "Part two test")
  )

