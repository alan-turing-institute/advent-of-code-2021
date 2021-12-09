#lang racket

; sufficiently different part1 and part2 impl today
; part1 uses lists, part2 uses vectors

(define (parse-input input-str)
  (map
   (λ (line)
     (map (λ (c)
            (- (char->integer c) 48))
          (string->list line)))
   (string-split input-str)))

; transpose list of lists
(define (transpose xss)
  (apply map list xss))


(define (unidir-sweep xs)
  (for/list ([pre (append '(+inf.0) (take xs (sub1 (length xs))))]
             [x xs]
             [post (append (rest xs) '(+inf.0))]
             )
    (and (> pre x) (> post x))
    )
  
  )



(define (part-one input-str)
  (let ([xss (parse-input input-str)])

    (let
        ([h-low (map unidir-sweep xss)]
         [v-low (transpose (map unidir-sweep (transpose xss)))])

      (for/sum ([xs xss]
                [h-row h-low]
                [v-row v-low])
        (for/sum ([x xs]
                  [a h-row]
                  [b v-row]
                  #:when (and a b)
                  )
          (add1 x))))))
  


; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_9.txt"))
  
  (define answer-one (part-one instr))
  (display "answer 1\n")
  (display answer-one);

  )


; --------- TEST ---------

(module+ test
  (require rackunit)

  (define testin #<<EOS
2199943210
3987894921
9856789892
8767896789
9899965678
EOS
    )

  (check-equal? (part-one testin) 15 "Part one test")
  
  )

