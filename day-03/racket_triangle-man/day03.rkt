#lang racket/base

(require racket/list ; for argmax, filter-map
         racket/dict ; for dict-set, dict-ref
         racket/port ; for port->lines 
         )


(module+ main
  (define *diagnostic* (call-with-input-file "input.txt" parse-input ))
  
  (part-one *diagnostic*)
  (part-two *diagnostic*))


;; ----------------------------------------------------------------------

(module+ test
  (require rackunit)
  (define *input* #<<EOS
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
EOS
    )

  (define *diagnostic* (call-with-input-string *input* parse-input))
  
  (check-equal? (part-one *diagnostic*) 198)
  (check-equal? (part-two *diagnostic*) 230) 

  )

;; ----------------------------------------------------------------------

(define (part-one diagnostic)
  (let* ([modes (map mode (transpose diagnostic))]   ; eg, '(#\1 #\0 #\1 #\1 #\0)
         [γ (string->number (list->string modes) 2)]
         [ε (bitwise-xor γ (- (expt 2 (length modes)) 1))])
    (* γ ε)))

(define (part-two diagnostic)
  (define (id bit) bit)
  (define (flip bit) (if (char=? bit #\0) #\1 #\0))

  (define O₂-rating
    (string->number (list->string (filter-until-one-remaining diagnostic '() id)) 2))
  (define CO₂-rating
    (string->number (list->string (filter-until-one-remaining diagnostic '() flip)) 2))

  (* O₂-rating CO₂-rating))


(define (filter-until-one-remaining ratings bits-so-far on-bit)
  (if (null? (cdr ratings))
      (append (reverse bits-so-far) (car ratings))
      (let ([m (on-bit (mode (map car ratings)))])
        (filter-until-one-remaining (filter-ratings ratings m) (cons m bits-so-far) on-bit))))

(define (filter-ratings ratings m)
  (filter-map (λ (r) (and (eq? m (car r))
                          (cdr r))) ratings))




;; Utilites
;; --------

;; Most frequent element in xs, breaking ties with char>?
(define (mode xs)
  (let ([counts (tabulate xs)])
    (car (argmax cdr (sort counts (λ (x₁ x₂) (char>? (car x₁) (car x₂))))))))

;; Count occurences of each x ∈ xs
(define (tabulate xs)
  (for/fold ([counts (map (λ (s) (cons s 0)) (remove-duplicates xs))])
            ([x (in-list xs)])
    (dict-set counts x (+ 1 (dict-ref counts x)))))


;; Parsing
;; -------

(define (transpose ls)
  (apply map list ls))

(define (parse-input prt)
  (map string->list (port->lines prt)))

