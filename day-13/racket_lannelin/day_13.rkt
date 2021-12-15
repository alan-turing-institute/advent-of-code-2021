#lang racket


; return (coords, folds)
; coords is hashtable of pair->num (reasoning in part 1 comment), folds is list of pairs
(define (parse-input input-str)
  (let ([top-split (string-split input-str "\n\n")])
    (let ([coords-str (first top-split)]
          [folds-str (second top-split)])
    
      (let ( ; for coords just split by lines then by , and convert fromm string
            [coords (map (λ (coord-str) (map string->number (string-split coord-str ","))) (string-split coords-str))]
            ;for folds, take the third "word", i.e. the coord e.g. x=4
            ;split this by =
            [folds (map (λ (fold-str) (string-split (third (string-split fold-str)) "=")) (string-split folds-str "\n"))])

          
        ; returrn coords as hashtable (all map to 0) and folds with numeric converted
        (values
         (make-immutable-hash (map (λ (coord) (cons coord 0)) coords))
         (map (λ (fold) (cons (first fold) (string->number (second fold)))) folds))))))



; given point p and fold-loc z return remapped point p2
(define (point-remap point fold-loc)
  (if (< fold-loc point)
      ; point will be remapped after folding
      (- point (* (- point fold-loc) 2))
      ; else not affected
      point))
    
; given coord list (x y) and fold ([xy] n) return remapped coord (x2 y2)
(define (coord-remap coord fold)
  (if (equal? (car fold) "y")
      ; if y fold
      (list (first coord) (point-remap (second coord) (cdr fold))) 
      ; must be x
      (list (point-remap (first coord) (cdr fold)) (second coord))))


; use a hash table as couldn't figure out equivalent set initialisation. Slight memory cost
; take initial-coords (list of lists) and folds (list of pairs)
; return list of corrds
(define (paper-folds initial-coords folds)
  (let ([final-coords (for/fold ([coords initial-coords])
                                ([fold folds])
                        ; fold and construct new hash table with folded coords
                        (make-immutable-hash (map (λ (coord) (cons (coord-remap coord fold) 0)) (hash-keys coords)))
                        )])
 
    (hash-keys final-coords)))


; take list of (x y) coords and print
; a bit messy due to padding but allows prettier output
(define (display-paper coords)
  (let ([rows (apply max (map second coords))]
        [columns (apply max (map first coords))])

    ; construct 2d vec to hold coords or zero
    (let ([vv (for/vector ([j (add1 rows)])
                (make-vector (add1 columns) 0))])

      ; set points in coords to 1
      (for ([coord coords])
        (vector-set! (vector-ref vv (second coord)) (first coord) 1))


      (displayln (list rows columns))
      (for ([i (+ columns 3)])
        (display " .") ; padding
        )
      (display "\n")
      (for ([j (add1 rows)])
        (display ". ") ; padding
        (for ([i (add1 columns)])
          (display " ") ; padding
          (if (zero? (vector-ref (vector-ref vv j) i))
              (display ".")
              (display "#")
              ))
        (display " . ") ; padding
        (display "\n"))
      (for ([i (+ columns 3)])
        (display " .") ; padding
        )
      (display "\n\n") ; end space
      )))


(define (part-one input-str)
  (let-values ([(coords folds) (parse-input input-str)])
    ; answer after first fold
    (length (paper-folds coords (take folds 1)))))
      

(define (part-two input-str)
  (let-values ([(coords folds) (parse-input input-str)])
    ; answer after first fold
    (display-paper (paper-folds coords folds))))

; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_13.txt"))
  
  (define answer-one (part-one instr))
  (display "answer 1\n")
  (display answer-one);

  (display "\n\n###\n\nanswer 2 (needs manual reading) \n\n")
  (define answer-two (part-two instr))
    
  (display answer-two)
  
  )


; --------- TEST ---------

(module+ test
  (require rackunit)

  (define testin #<<EOS
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
EOS
    )


  (check-equal? (part-one testin) 17 "Part one test a")

  (displayln  "manual check required: should look like a square!\n")
  (part-two testin)
  )
