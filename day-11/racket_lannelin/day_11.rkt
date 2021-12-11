#lang racket

; not the most readable - hopefully commented sufficiently
; doesn't feel very "functional", a fair few void ops. Natural consequence of vectors?


; receive multiline input, return 2dvec of ints
(define (parse-input input-str)
  (list->vector(map
                (λ (line)
                  (list->vector (map (λ (c)
                                       (- (char->integer c) 48))
                                     (string->list line))))
                (string-split input-str))))



; look up value from 2d vector
(define (vv-ref vec x y)
  (vector-ref (vector-ref vec x) y))

; set value on 2d vector
(define (vv-set! vec x y val)
  (vector-set! (vector-ref vec x) y val))


; vector-map doesn't seem to like lambdas so make this named
(define (vector-add1 v)
  (vector-map add1 v))

; add1 all items of 2d vector
(define (vv-add1-all vv)
  (vector-map vector-add1 vv))



; for getting inital flash values per step
(define (where-gt-9? vv)
  (filter-not empty? (let ([n (vector-length vv)]
                           [m (vector-length (vector-ref vv 0))]) ; assumes nonempty vv
                       (for*/list ([i n]
                                   [j m])
                         (if (> (vv-ref vv i j) 9)
                             ; if gt 9 return coord
                             (cons i j)
                             ; else return empty (to be filtered)
                             null
                             )))))


; adds 1 to given index, catching exception if index oob
(define (vv-add1 vv i j)

  (let ([row (vector-ref vv i)])
    (vector-set! row j (add1 (vector-ref row j)))))



(define (flash! vv i j seen)
  (set-add! seen (cons i j))
  (add-maybe-flash! vv (sub1 i) (sub1 j) seen) ; NW (top left)
  (add-maybe-flash! vv i (sub1 j) seen) ; N
  (add-maybe-flash! vv (add1 i) (sub1 j) seen) ; NE
  (add-maybe-flash! vv (add1 i) j seen) ; E
  (add-maybe-flash! vv (add1 i) (add1 j) seen) ; SE
  (add-maybe-flash! vv i (add1 j) seen) ; S
  (add-maybe-flash! vv (sub1 i) (add1 j) seen) ; SW
  (add-maybe-flash! vv (sub1 i) j seen) ; W
  void
  )


; is valid index, i j coords, m n vv shape
(define (is-valid-coord? i j m n)
  (not (or (or (< i  0) (< j  0)) (or (>= i n) (>= j m)))))

; add and then flash if necessary
; extra add to coord already supposed to flash doesn't matter
(define (add-maybe-flash! vv i j seen)
  (if (is-valid-coord? i j (vector-length vv) (vector-length (vector-ref vv 0)))
      ; coord is valid
      (let ([coord (cons i j)])
        ; add 1
        (vv-add1 vv i j)
        (if (and (not (set-member? seen coord)) (> (vv-ref vv i j) 9))
            ;  not seen and gt 9 so flash
            (flash! vv i j seen)
            ; otherwise nothing
            void))
      ; otherwise nothing
      void
      ))


; add1 to all
; loop: >9flash, increment adjacent (inc diag)
; note only 1 flash per step per octopus
; addition step gives new vv so no side effects here, return instead
(define (step vv-start)
  ; add one - this returns a new object
  (let ([vv (vv-add1-all vv-start)])

    ; empty set to add flashed octos to
    (let ([seen (mutable-set)])
        
      ; un-funtional, loop and perform void ops
      ; for each initial >9 coord, flash (and potentially recurse)
      (for ([coord (where-gt-9? vv)])
        (add-maybe-flash! vv (car coord) (cdr coord) seen)
        )
        
      ; void ops again
      ; for each coord that flashes, set value to 0
      (for ([coord seen])
        (vv-set! vv (car coord) (cdr coord) 0)
        )
        
      ; return values that were modified in void op loops
      (values vv (set-count seen))))
  )


; PART ONE
(define (part-one input-str)

  
  (let-values ([(total-flashes vv-final) 
                (for/fold ([flashes 0]
                           [vv (parse-input input-str)])
                          ([i 100])
              
                  (let-values ([(vv-prime round-flashes) (step vv)])
                    (values (+ flashes round-flashes) vv-prime)))
            
                ])
    total-flashes
    )
  )


; PART TWO
; basically early exit of part 1 with track of i
(define (part-two input-str max-iter)

  (let ([initial-vv (parse-input input-str)])
    (let ([m (vector-length initial-vv)] [n (vector-length (vector-ref initial-vv 0))])
      ; get total no. of octos so we know when to stop early
      (let ([n-octo (* m n)])
        
        (let-values ([(final-i final-flashes vv-final) 
                      (for/fold ([last-i 0]
                                 [last-flashes 0]
                                 [vv initial-vv])
                                ([i max-iter]
                                 #:break (equal? n-octo last-flashes))
              
                        (let-values ([(vv-prime round-flashes) (step vv)])
                          (values i round-flashes vv-prime))
            
                        )])
          (add1 final-i))

        )
      )
    )
  )



; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_11.txt"))
  
  (define answer-one (part-one instr))
  (display "answer 1\n")
  (display answer-one);

  (define answer-two (part-two instr 500))
  (display "\n\n###\n\nanswer 2\n")
  (display answer-two)
  
  )


; --------- TEST ---------

(module+ test
  (require rackunit)

  (define testin #<<EOS
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
EOS
    )

  (check-equal? (part-one testin) 1656 "Part one test")
  
  (check-equal? (part-two testin 200) 195 "Part two test")
  )

