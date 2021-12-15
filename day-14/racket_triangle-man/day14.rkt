#lang racket

(require memoize)

(module+ main
  (define p (open-input-file "input.txt"))

  (define *template*
    (string->list (read-line p)))

  (read-line p)
  
  (define *rules*
    (read-rules p))

  ;; Part one
  (define part-one (dict-remove (polymerise *template* *rules* 10) #f))
  (/ (- (apply max (dict-values part-one))
        (apply min (dict-values part-one)))
     2)

  ;; Part two
  (define part-two (dict-remove (polymerise *template* *rules* 40) #f))
  (/ (- (apply max (dict-values part-two))
        (apply min (dict-values part-two)))
     2)

  )


(define (polymerise polymer rules N)
  ;; Internal definition to avoid repeating `rules`
  (define/memo* (polymerise-dimer dimer N)
    (let ([fst (car dimer)]
          [snd (cadr dimer)])
      (if (zero? N)
          (if (eq? fst snd)
              (hash fst 2)
              (hash fst 1 snd 1))
          (let ([insertion (element-lookup dimer rules)])
            (if (not insertion)
                (polymerise-dimer dimer 0)
                (add-to-counts
                 (polymerise-dimer (list fst insertion) (- N 1))
                 (polymerise-dimer (list insertion snd) (- N 1))))))))
  ;;
  (let ([dimers (dimerise polymer)]
        [zeros  (count-table (cons #f (remove-duplicates (dict-values rules))))])
    (for/fold ([counts zeros])
              ([dimer (in-list dimers)])
      (add-to-counts counts (polymerise-dimer dimer N)))))

;; Add spurious dimers fore and aft to make the counts work
(define (dimerise xs)
  (for/list ([fst (cons #f xs)]
             [snd (append xs '(#f))])
    (list fst snd)))

(define (element-lookup dimer rules)
  (dict-ref rules dimer (thunk #f)))

;; ----------------------------------------------------------------------
;; Utilities

(define (count-table xs)
  (make-immutable-hash (map (curryr cons 0) xs)))

(define (add-to-counts tbl1 tbl2)
  (for/fold ([tbl tbl1])
            ([(monomer count) (in-hash tbl2)])
    (dict-update tbl monomer (curry + count) (thunk 0))))


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
