#lang racket

(require graph)


(module+ main
  
  (define *rows*
    (with-input-from-file "input.txt" read-cavern))

  (define *cavern* (make-cavern *rows*))
  
  ;; Part one
  (displayln "Part one:")
  (time
   (define-values (cost# prev#) (dijkstra *cavern* '(0 0)))
   (define max-row (apply max (map car (get-vertices *cavern*))))
   (define max-col (apply max (map cadr (get-vertices *cavern*))))
   
   (dict-ref cost# (list max-row max-col)))

  (displayln "Part two:")
  ;; Part two
  (displayln "Making big cavern...")
  (define *big-cavern* (make-big-cavern *rows*))

  (displayln "Computing shorterst path...")
  (time
   (define-values (cost# prev#) (dijkstra *big-cavern* '(0 0)))
   (define max-row (apply max (map car (get-vertices *big-cavern*))))
   (define max-col (apply max (map cadr (get-vertices *big-cavern*))))
   
   (dict-ref cost# (list max-row max-col)))
  
  )

(define (make-big-cavern rows)
  (let ([height (length rows)]
        [width  (length (car rows))])
    (let ([edges 
           (append*
            (for*/list ([(row  r) (in-indexed rows)]
                        [(risk c) (in-indexed row)])
              (append*
               (for*/list ([R 5]
                           [C 5])
                 (let ([here (list (+ r (* R height)) (+ c (* C width)))])
                   (map (λ (nb) (list
                                 (+ 1 (remainder (+ (- risk 1) R C) 9))
                                 nb
                                 here)) ; An edge
                        (neighbours (* width 5) (* height 5) here)))))))])
      (weighted-graph/directed edges))))

;; ----------------------------------------------------------------------
;; Parsing

;; Produce a directed graph
;; - nodes are the grid locations, as a list, eg, (0 0) is the start
;; - edges are the risk of entering the location at the head of the edge
(define (make-cavern rows)
  (let ([height (length rows)]
        [width  (length (car rows))])
    (let ([edges 
           (append*
            (for*/list ([(row  r) (in-indexed rows)]
                        [(risk c) (in-indexed row)])
              (let ([here (list r c)])
                (map (λ (nb) (list risk nb here)) ; An edge
                     (neighbours width height here)))))])
      (weighted-graph/directed edges))))

;; Produce a list of list of numbers
(define (read-cavern)
  (for/list ([row (in-lines)])
    (map (compose string->number string)
         (string->list row))))


;; Down or to the right, if in range
(define (neighbours width height loc)
  (filter (in-range? width height)
          (map (curry loc-+ loc)
               '((1 0) (0 1) (-1 0) (0 -1)))))

(define (loc-+ loc δ)
  (map + loc δ))

(define ((in-range? width height) loc)
  (let ([row (car loc)]
        [col (cadr loc)])
    (and
     (>= row 0)
     (<  row height)
     (>= col 0)
     (<  col width))))




(module+ test
  (require rackunit)


  
  (define *rows*
    (with-input-from-string #<<EOS
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
      read-cavern))

  (define-values (cost# prev#) (dijkstra (make-cavern *rows*) '(0 0)))
  (check-equal? (dict-ref cost# '(9 9)) 40)

  (define-values (big-cost# big-prev#) (dijkstra (make-big-cavern *rows*) '(0 0)))
  (check-equal? (dict-ref big-cost# '(49 49)) 315)

  )

