#lang racket

; part 2 using vecs
; running a bit short on time so gets a bit ugly for calcing basin!

(define (parse-input input-str)
  (map
   (λ (line)
     (map (λ (c)
            (- (char->integer c) 48))
          (string->list line)))
   (string-split input-str)))


; look up value from 2d vector, returning oob-val on oob
(define (get2v vec x y oob-val)
  ; not sure of the actual exception? this is too broad but works in this limited scenario
  (with-handlers ([exn:fail:contract?
                   (λ (exn) oob-val)])
    (vector-ref (vector-ref vec x) y)))


(define (low-point-locs vv)

  (filter-not empty? (let ([n (vector-length vv)]
                           [m (vector-length (vector-ref vv 0))])
                       (for*/list ([i n]
                                   [j m])
                         (let ([x (get2v vv i j 9)]
                               [above (get2v vv (sub1 i) j 9)]
                               [below (get2v vv (add1 i) j 9)]
                               [left (get2v vv i (sub1 j) 9)]
                               [right (get2v vv i (add1 j) 9)]
                               )
                           (if 
                            (and (< x above) (and (< x below) (and (< x left) (< x right))))                      
                            ;is low point
                            (cons i j)
                            ;else
                            '()))   
                         ))))

(define (basin-sum vv i j seen)
  (set-add! seen (cons i j))
  ; allow traverse of entire grid in nested for
  (let          ([up-ij    (cons (sub1 i) j)]
                 [down-ij  (cons (add1 i) j)]
                 [left-ij  (cons i (sub1 j))]
                 [right-ij (cons i (add1 j))]
                 )
    (add1 (for/sum ([coord (list up-ij down-ij left-ij right-ij)])
            (if (set-member? seen coord)
                ; if already seen
                0
                (let ([val (get2v vv (car coord) (cdr coord) 9)])
                  ; otherwise add to seen
                  (set-add! seen coord)
                  ; check if val is 9
                  (if (equal? val 9)
                      ; is 9
                      0
                      ;otherwise recurse
                      (basin-sum vv (car coord) (cdr coord) seen)     
                      )))))))

  
(define (part-two input-str)
  (let ([vv (list->vector (map list->vector (parse-input input-str)))])
    
    (let ([basin-sizes (map (λ (coord) (basin-sum vv (car coord) (cdr coord) (mutable-set '()))) (low-point-locs vv))])

      (apply * (take (sort basin-sizes >) 3)))
    ))


; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_9.txt"))

  (define answer-two (part-two instr))
  (display "answer 2\n")
  (display answer-two)
  
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
  
  (check-equal? (part-two testin) 1134 "Part two test")
  )
