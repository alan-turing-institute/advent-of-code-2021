#lang racket


(module+ main
  
  (define *input* #<<EOS
7147713556
6167733555
5183482118
3885424521
7533644611
3877764863
7636874333
8687188533
7467115265
1626573134
EOS
    )
  
  (define *octopodes*
    (call-with-input-string *input* read-grid))

  ;; Part one
  (let-values ([(final count) (run-for *octopodes* 100)])
    count)

  ;; Part two
  (run-until *octopodes* (curry equal? 100))
  )


(define (run-for os steps)
  (for/fold ([os      os]
             [flashes 0])
            ([_ steps])
    (let-values ([(os₁ flash-count) (step os)])
      (values os₁ (+ flashes flash-count)))))

(define (run-until os pred?)
  (let loop ([os    os]
             [steps 1])
    (let-values ([(os₁ flash-count) (step os)])
      (if (pred? flash-count)
          steps
          (loop os₁ (+ steps 1))))))


;; ----------------------------------------------------------------------

;; Returns (values os count)
(define (step os)
  (let ([os₁ (struct-copy grid os
                          [vs (vector-map (curry + 1) (grid-vs os))])])
    (flash! os₁ (grid-locns-where os₁ will-flash?))
    ;; Reset flashed to zero
    (values
     (struct-copy grid os₁
                  [vs (vector-map (λ (v) (or v 0)) (grid-vs os₁))])
     (vector-count not (grid-vs os₁)))))

;; Repeatedly flash, mutating os
(define (flash! os flash-list)
  (unless (null? flash-list)
    ;; Set flashed to #f
    (for ([flashed (in-list flash-list)])
      (grid-set! os flashed #f))
    ;; Update neighbours
    (define update-list
      (filter
       (curry grid-ref os)  ; remove those which have already flashed
       (append-map (curry adjacent-to os) flash-list))) ; may have duplicates
    (for ([to-update (in-list update-list)])
      (grid-set! os to-update (+ 1 (grid-ref os to-update))))
    ;;
    (flash! os (grid-locns-where os will-flash?))))

(define (will-flash? v)
  (and v (> v 9)))

(define (adjacent-to g loc)
  (filter
   (curry in-range? g)
   (map
    (λ (δ) (map + loc δ))
    '((0 1) (1 1) (1 0) (1 -1) (0 -1) (-1 -1) (-1 0) (-1 1)))))



;; Grids
;; -----

(struct grid (cols vs) #:transparent)

(define (make-grid rows cols [init 0])
  (make-vector (* rows cols) init))

(define (grid-rows g)
  (/ (vector-length (grid-vs g)) (grid-cols g)))

(define (grid-ref g loc)
  (let ([row (car loc)]
        [col (cadr loc)])
    (vector-ref (grid-vs g) (+ col (* row (grid-cols g))))))

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
     (apply string-append
            (for/list ([col (grid-cols g)])
              (number->string (grid-ref g `(,row ,col))))))
   "\n"))

(define (grid-display g)
  (display (grid-print g)))

;; Parsing
;; -------

(define (read-grid p)
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

  (define *octopodes*
    (call-with-input-string *input* read-grid))

  (define-values (final count) (run-for *octopodes* 100))
  (check-equal? 1656 count)

    ;; Part two
  (check-equal?
   195
   (run-until *octopodes* (curry equal? 100)))

  
  )
