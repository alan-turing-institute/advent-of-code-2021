#lang racket/base

(require threading)
(require racket/string)
(require racket/vector)
(require racket/match)
(require racket/port)


(module+ main
  (define *segments*
    (~>>
     (call-with-input-file "input.txt" read-segments)
     (filter segment-h-or-v?)))

  (count-danger-points *segments*)

  )



(module+ test
  (require rackunit)
  (define *input* #<<EOS
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
EOS
    )

  (define *segments*
    (~>>
     (call-with-input-string *input* read-segments)
     (filter segment-h-or-v?)))

  (check-equal? (count-danger-points *segments*) 5))




(define (count-danger-points segments)
  (let* ([max-x (max (apply max (map segment-x₁ segments))
                     (apply max (map segment-x₂ segments)))]
         [max-y (max (apply max (map segment-y₁ segments))
                     (apply max (map segment-y₂ segments)))]
         [seabed (make-grid (+ max-x 1) (+ max-y 1))])
    (printf "Read ~a segments with upper-right at (~a, ~a)\n" (length segments) max-x max-y)

    (for ([s (in-list segments)])
      (let ([pixels (rasterise s)])
        (for ([pixel (in-list pixels)])
          (let ([x (car pixel)]
                [y (cdr pixel)])
            (grid-set! seabed x y (+ 1 (grid-ref seabed x y)))))))

    (vector-count (λ (n) (>= n 2))  (grid-pixels seabed))))




;; Line segments
;; -------------

(struct segment (x₁ y₁ x₂ y₂) #:transparent)

(define (segment-horizontal? seg)
  (equal? (segment-y₁ seg) (segment-y₂ seg)))

(define (segment-vertical? seg)
  (equal? (segment-x₁ seg) (segment-x₂ seg)))

(define (segment-h-or-v? seg)
  (or (segment-horizontal? seg)
      (segment-vertical? seg)))

;; Assumes seg is either horizontal or vertical
;; rasterise : segment? -> [List-of (number? number?)]
(define/match (rasterise seg)
  [((segment x₁ y₁ x₂ y₂))
   (cond
     [(equal? x₁ x₂) (for/list ([y (in-range (min y₁ y₂) (+ 1 (max y₁ y₂)))])
                       (cons x₁ y))]
     [(equal? y₁ y₂) (for/list ([x (in-range (min x₁ x₂) (+ 1 (max x₁ x₂)))])
                       (cons x y₁))]
     [else           (raise-user-error "Can't handle diagonals" seg)])])


;; Grids
;; -----

(struct grid (x-len y-len pixels) #:transparent)

(define (make-grid x-len y-len)
  (grid x-len y-len (make-vector (* x-len y-len) 0)))

(define (grid-ref g x y)
  (vector-ref (grid-pixels g) (+ (* x (grid-x-len g)) y)))

(define (grid-set! g x y v)
  (vector-set! (grid-pixels g) (+ (* x (grid-x-len g)) y) v))



;; Parsing
;; -------

(define (parse-segment l)
  (match-let* ([`(,start "->" ,end) (string-split l)]
               [`(,x₁ ,y₁)      (string-split start ",")]
               [`(,x₂ ,y₂)      (string-split end ",")])
    (segment (string->number x₁)
             (string->number y₁)
             (string->number x₂)
             (string->number y₂)))
  )

(define (read-segments p)
  (for/list ([l (in-lines p)])
    (parse-segment l)))
