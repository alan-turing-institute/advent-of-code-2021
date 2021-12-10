#lang racket/base

(require racket/port
         racket/function
         racket/set
         racket/list)

(module+ main

  (define *grid*
    (call-with-input-file "input.txt" read-map))

  (part-one *grid*)
  (part-two *grid*)
  )



;; ----------------------------------------------------------------------
;; Part one

(define (part-one g)
  (apply +
         (map
          (compose (curry + 1) (curry grid-ref g))
          (find-lows g))))
              

;; ----------------------------------------------------------------------
;; Part two

(define (part-two g)
  (let* ([basins (map (curry expand-basin g)
                      (find-lows g))]
         [sizes (sort (map length basins) >)])
    (* (car sizes) (cadr sizes) (caddr sizes))))

(define (expand-basin g low-loc)
  (expand-basin* g (list low-loc) '()))

(define (expand-basin* g next in-basin)
  (if (null? next)
      in-basin
      (let ([where-now (apply set-union (map (expand-next g) next))])
        (expand-basin* g (set-subtract where-now in-basin) (set-union where-now in-basin)))))

;; Return a list of positions next to this one whose values are not 9
(define ((expand-next g) loc)
  (let ([v      (grid-ref g loc)]
        [height (grid-rows g)]
        [width  (grid-cols g)])
    (define (in-range? row col)
      (and (>= row 0)
           (<  row height)
           (>= col 0)
           (<  col width)))
    (filter-map
     (λ (δ)
       (let ([row (+ (car loc) (car δ))]
             [col (+ (cadr loc) (cadr δ))])
         (and
          (in-range? row col)
          (not (eq? (grid-ref g `(,row ,col)) 9))
          `(,row ,col))))
     '((0 -1) (1 0) (0 1) (-1 0)))))

(define (find-lows g)
  (filter values
          (for*/list ([row (grid-rows g)]
                      [col (grid-cols g)])
            (maybe-low g `(,row ,col)))))

;; Return #f or the value at row, col if it is a minimum
(define (maybe-low g loc)
  (let ([height (grid-rows g)]
        [width  (grid-cols g)]
        [v      (grid-ref g loc)]
        [row    (car loc)]
        [col    (cadr loc)])
    (define (not-in-range? row col)
      (or (<  row 0)
          (>= row height)
          (<  col 0)
          (>= col width)))
    (let ([low?
           (for/and ([δr (in-list '(-1 0 1  0))]
                     [δc (in-list '( 0 1 0 -1))])
             (or (not-in-range? (+ row δr) (+ col δc))
                 (< v (grid-ref g `(,(+ row δr) ,(+ col δc))))))])
      (if low? loc #f))))


;; Grids
;; -----

(struct grid (cols vs) #:transparent)

(define (make-grid rows cols [init 0])
  (make-vector (* rows cols) init))

(define (grid-ref g loc)
  (let ([row (car loc)]
        [col (cadr loc)])
    (vector-ref (grid-vs g) (+ col (* row (grid-cols g))))))

(define (grid-set! g loc val)
  (let ([row (car loc)]
        [col (cadr loc)])
    (vector-set! (grid-vs g) (+ col (* row (grid-cols g))) val)))

(define (grid-rows g)
  (/ (vector-length (grid-vs g)) (grid-cols g)))


;; Parsing
;; -------

(define (read-map p)
  ;; Read heights
  (define rows
    (for/list ([line (in-list (port->lines p))])
      (map (compose string->number string) (string->list line))))
  ;; Create grid 
  (let ([heights 
         (for*/vector ([row (in-list rows)]
                       [val (in-list row)])
           val)])
    (grid (length (car rows)) heights)))




;; ----------------------------------------------------------------------

(module+ test
  (require rackunit)

  (define *input* #<<EOS
2199943210
3987894921
9856789892
8767896789
9899965678
EOS
)

  (define *grid*
    (call-with-input-string *input* read-map))

  (check-equal? 15 (part-one *grid*))
  (check-equal? 1134 (part-two *grid*))
  )
