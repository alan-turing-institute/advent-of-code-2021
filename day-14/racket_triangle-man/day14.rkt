#lang racket

(module+ main
  (define p (open-input-file "input.txt"))

  (define *template*
    (string->list (read-line p)))

  (read-line p)
  
  (define *rules*
    (read-rules p))

  ;; Part one
  (define part-one (tabulate (polymerise *template* *rules* 10)))

  (- (apply max (dict-values part-one))
     (apply min (dict-values part-one)))
  
  )

(define (polymerise polymer rules N)
  (undimerise
   (for/fold ([dimers (dimerise polymer)])
             ([_ N])
     (append-map (insert-between rules) dimers))))

(define (dimerise xs)
  (reverse
   (let loop ([rest   (cons #f xs)]
              [so-far '()])
     (if (null? (cdr rest))
         (cons (list (car rest) #f) so-far)
         (loop (cdr rest) (cons (list (car rest) (cadr rest)) so-far))))))

(define (undimerise ds)
  (map car (cdr ds)))

(define ((insert-between rules) dimer)
  (let ([new-element (element-lookup dimer rules)])
    (if (not new-element)
        (list dimer)
        (list (list (car dimer) new-element)
              (list new-element (cadr dimer))))))

(define (element-lookup dimer rules)
  (dict-ref rules dimer (thunk #f)))

;; ----------------------------------------------------------------------
;; Utilities

;; Count occurences of each x ∈ xs
(define (tabulate xs)
  (for/fold ([counts (map (λ (s) (cons s 0)) (remove-duplicates xs))])
            ([x (in-list xs)])
    (dict-set counts x (+ 1 (dict-ref counts x)))))


;; ----------------------------------------------------------------------
;; Parsing

;; -> dictionary
(define (read-rules p)
  (for/hash ([line (in-lines p)])
    (match (string-split line " -> ")
      [`(,target-pair, insertion)
       (values (string->list target-pair) (car (string->list insertion)))])))

;; ----------------------------------------------------------------------

(module+ test
  (require rackunit)

  (define *template*
    (string->list "NNCB"))

  (define p
    (open-input-string
     #<<EOS
CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
EOS
     ))
  
  (define *rules* (read-rules p))


  )
