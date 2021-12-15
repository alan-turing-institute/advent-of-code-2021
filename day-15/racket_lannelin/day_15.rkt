#lang racket

(require data/heap)

; receive multiline input, return 2dvec of ints
(define (parse-input input-str)
  (list->vector(map
                (λ (line)
                  (list->vector (map (λ (c)
                                       (- (char->integer c) 48))
                                     (string->list line))))
                (string-split input-str))))


; create 2d vector of zeros
(define (vv-zeros m n)
  (for/vector ([i m])
    (make-vector n)
    ))

; look up value from 2d vector
(define (vv-ref vec coord)
  (vector-ref (vector-ref vec (first coord)) (second coord)))

; transpose 2d vector
(define (vv-transpose vv)
  (let ([m (vector-length vv)] [n (vector-length (vector-ref vv 0))])
    (let ([transposed (vv-zeros n m)])
      (for* ([i m] [j n])
        (vector-set! (vector-ref transposed j) i (vv-ref vv (list i j))))
      transposed)))


; is valid index, i j coords, m n vv shape
(define (is-valid-coord? i j m n)
  (not (or (or (< i  0) (< j  0)) (or (>= i n) (>= j m)))))

(define (neighbours vv initial-coord m n)
  (let ([i (first initial-coord)] [j (second initial-coord)])
    (filter (λ (coord) (is-valid-coord? (first coord) (second coord) m n)) (list
                                                                            (list (sub1 i) j)
                                                                            (list (add1 i) j)
                                                                            (list i (sub1 j))
                                                                            (list i (add1 j))))))
                           



(define (create-initial-vertex-set m n val)
  (make-hash (map (λ (coord) (cons coord val)) (for*/list ([i m] [j n]) (list i j)))))



(define (min-dist-key dists keys)
  (let-values ([(final-min-key minval) (for/fold ([min-key null] [min-val +inf.0])
                                                 ([k keys])
                                         (let ([v (hash-ref dists k)])
                                           (if (< v min-val)
                                               ; update min
                                               (values k v)
                                               ; else keep same
                                               (values min-key min-val))))])
    final-min-key))
      


; comparison func for heap - want to be able to store key and value but just compare on value
(define (lower-cost? a b)
  (< (cdr a) (cdr b))
  )


; implementation based on priority queue algo pseudocode here: https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
(define (djikstra-w-target vv m n source target)
  
  (let ([dists (create-initial-vertex-set m n +inf.0)] [prev (make-hash)])
    ; create heap and add initial keys (except source)
    (let ([Q (make-heap lower-cost?)])
      (for ([k (hash-keys dists)]
            #:unless (equal? k source))
        (heap-add! Q (cons k +inf.0)))
      
      ; set source dist to 0
      (hash-set! dists source 0)
    
      ; recursive - uses state from outer function for Q dists prev target
      (define (update-step u)
        (for ([v (neighbours vv u m n)])
          ;#:when (hash-has-key? Q v))
          (let ([alt (+ (hash-ref dists u) (vv-ref vv v))])
            (if (< alt (hash-ref dists v))
                (let ([just-want-multi-actions -])
                  (hash-set! dists v alt)
                  (hash-set! prev v u)
                  (heap-remove! Q (cons v alt))
                  (heap-add! Q (cons v alt)))
                void)))


        (let ([next (car (heap-min Q))])
          ; now remove min from heap
          (heap-remove-min! Q)
          (if (equal? target next)
              ; if next is target return total dist for this
              (hash-ref dists target)
              ; otherwise recurse
              (update-step next)
              )))

      
      (update-step source)
       
      )))
      


; tile out in horizontal direction, addinig 1 with each tile
(define (expand-cols vv n)
  (for/vector ([i (vector-length vv)])
     (let ([v (vector-ref vv i)])
     (apply vector-append
            (for/list ([z n])
              ; modulo but starts at 1
              (vector-map (λ (x) (add1 (modulo (sub1 (+ x z)) 9))) v))))))

; tile out cave in both horizontal and vertical directions incrementing by 1 with each tile
(define (create-larger-cave vv n)
  (vv-transpose (expand-cols (vv-transpose (expand-cols vv n)) n)))
    

(define (part-one input-str)
  (let ([vv (parse-input input-str)])
    (let ([m (vector-length vv)] [n (vector-length (vector-ref vv 0))] )
      (djikstra-w-target vv m n '(0 0) (list (sub1 m) (sub1 n)))
      )))


(define (part-two input-str)
  (let ([vv (create-larger-cave (parse-input input-str) 5)])
    (let ([m (vector-length vv)] [n (vector-length (vector-ref vv 0))] )
      (djikstra-w-target vv m n '(0 0) (list (sub1 m) (sub1 n)))
      )))


; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_15.txt"))
  
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

  (define testin #<<EOS
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
EOS
    )


  (check-equal? (part-one testin) 40 "Part one test")

  (check-equal? (part-two testin) 315 "Part two test")

  )

