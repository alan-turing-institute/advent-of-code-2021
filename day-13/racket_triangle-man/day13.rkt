#lang racket

(module+ main
  
  (define *input* (open-input-file "input.txt"))
  (define *paper* (read-paper *input*))
  (define *folds* (read-folds *input*))

  ;; Part 1
  (vector-length (vector-filter values (grid-vs (paper-fold *paper* (car *folds*)))))

  ;; Part 2
  (grid-display
   (for/fold ([paper *paper*])
             ([f (in-list *folds*)])
     (paper-fold paper f)))
  
  )


;; Folding

;; grid fold -> grid
(define (paper-fold G f)
  (if (eq? (car f) 'x)
      (paper-fold/x G (cadr f))
      (paper-fold/y G (cadr f))))

(define (paper-fold/x G col-to-fold)
  (let ([G′ (make-grid (grid-rows G) col-to-fold)])
    (for* ([r (grid-rows G′)]
           [c (grid-cols G′)])
      (grid-set! G′ `(,r ,c)
                 (or
                  (grid-ref G `(,r ,c))
                  (grid-ref/default G `(,r ,(- (* 2 col-to-fold) c)) #f))))
    G′))

(define (paper-fold/y G row-to-fold)
  (let ([G′ (make-grid row-to-fold (grid-cols G))])
    (for* ([r (grid-rows G′)]
           [c (grid-cols G′)])
      (grid-set! G′ `(,r ,c)
                 (or
                  (grid-ref G `(,r ,c))
                  (grid-ref/default G `(,(- (* 2 row-to-fold) r) ,c) #f))))
    G′))




;; Grids
;; -----

(module grid racket

  (provide grid
           make-grid
           grid-rows
           grid-cols
           grid-vs
           grid-ref
           grid-ref/default
           grid-set!
           grid-display
           )
  
  (struct grid (cols vs) #:transparent)

  (define (make-grid rows cols [init #f])
    (grid cols (make-vector (* rows cols) init)))
  
  (define (grid-rows g)
    (/ (vector-length (grid-vs g)) (grid-cols g)))
  
  (define (grid-ref g loc)
    (let ([row (car loc)]
          [col (cadr loc)])
      (vector-ref (grid-vs g) (+ col (* row (grid-cols g))))))
  
  (define (grid-ref/default g loc default)
    (let ([row (car loc)]
          [col (cadr loc)])
      (if (and
           (>= row 0)
           (<  row (grid-rows g))
           (>= col 0)
           (<  col (grid-cols g)))
          (vector-ref (grid-vs g) (+ col (* row (grid-cols g))))
          default)))
  
  (define (grid-set! g loc val)
    (let ([row (car loc)]
          [col (cadr loc)])
      (vector-set! (grid-vs g) (+ col (* row (grid-cols g))) val)))
  
  (define (grid-index->location g idx)
    (let-values ([(row col) (quotient/remainder idx (grid-cols g))])
      (list row col)))
  
  (define (grid-locns-where g pred?)
    (map
     (curry grid-index->location g)
     (for/list ([v (in-vector (grid-vs g))]
                [i (in-naturals)]
                #:when (pred? v))
       i)))
  
  (define (in-range? g loc)
    (let ([row (car loc)]
          [col (cadr loc)])
      (and
       (>= row 0)
       (<  row (grid-rows g))
       (>= col 0)
       (<  col (grid-cols g)))))
  
  (define (grid-print g)
    (string-join
     (for/list ([row (grid-rows g)])
       (list->string
        (for/list ([col (grid-cols g)])
          (if (grid-ref g `(,row ,col)) #\# #\.))))
     "\n"))
  
  (define (grid-display g)
    (display (grid-print g)))
  
  )

(require 'grid)

;; ----------------------------------------------------------------------
;; Parsing

;; Input is `col,row`, whereas a location is (row col)
(define (read-paper p)
  (let ([locations 
         (for/list ([coord (in-lines p)])
           #:break (not (non-empty-string? coord))
           (map string->number (string-split coord ",")))])
    (let ([max-row (apply max (map cadr locations))]
          [max-col (apply max (map car locations))])
      (let ([paper (make-grid (+ max-row 1) (+ max-col 1))])
        (for ([loc (in-list locations)])
          (grid-set! paper `(,(cadr loc) ,(car loc)) #t))
        paper))))

(define (read-folds p)
  (for/list ([row (in-lines p)])
    (let ([fold-line (caddr (string-split row " "))])
      (match (string-split fold-line "=")
        [`(,axis ,coord) `(,(string->symbol axis) ,(string->number coord))]))))


;; ----------------------------------------------------------------------

(module+ test
  (require rackunit)
  
  (define *input* (open-input-string #<<EOS
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
                                     ))

  (define *paper* (read-paper *input*))
  (define *folds* (read-folds *input*))

  (check-equal? (vector-length (vector-filter values (grid-vs (paper-fold *paper* (car *folds*)))))
                17)
  
  )
