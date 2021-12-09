#lang racket/base

(require racket/match
         racket/string
         racket/port
         racket/list
         racket/set
         racket/vector)

(module+ main
  (define *entries* (call-with-input-file "input.txt" read-notes))

  (part-one *entries*)
  (part-two *entries*))

;; ----------------------------------------------------------------------

(define (part-one entries)
  (define (known-digit? digit)
    (let ([n-segs (string-length digit)])
      (or (= n-segs 2)
          (= n-segs 3)
          (= n-segs 4)
          (= n-segs 7))))
  (for/sum ([note (in-list entries)])
    (count known-digit? (cdr note))))

(define (part-two entries)
  (for/sum ([note (in-list entries)])
    (string->number
     (apply string-append (map number->string (decode-note note))))))



(define (decode-note note)
  (let ([cribs            (map (compose list->seteq string->list) (car note))]
        [digits-to-decode (map (compose list->seteq string->list) (cdr note))]
        [decoder          (make-vector 10 #f)])
    
    ;; Find 1, 4, 7, and 8
    (for ([crib (in-list cribs)])
      (match (set-count crib)
        [2 (vector-set! decoder 1 crib)]
        [3 (vector-set! decoder 7 crib)]
        [4 (vector-set! decoder 4 crib)]
        [7 (vector-set! decoder 8 crib)]
        [_ (void)]
       ))
    ;; Find the others
    (for ([crib (in-list cribs)])
      (match (list (set-count crib)
                   (dot (vector-ref decoder 1) crib)
                   (dot (vector-ref decoder 4) crib)
                   (dot (vector-ref decoder 7) crib))
        ['(6 2 3 3) (vector-set! decoder 0 crib)]
        ['(5 1 2 2) (vector-set! decoder 2 crib)]
        ['(5 2 3 3) (vector-set! decoder 3 crib)]
        ['(5 1 3 2) (vector-set! decoder 5 crib)]
        ['(6 1 3 2) (vector-set! decoder 6 crib)]
        ['(6 2 4 3) (vector-set! decoder 9 crib)]
        [_ (void)]
        ))

    ;; Decode the digits
    (map
     (λ (digit) (vector-member digit decoder))
     digits-to-decode)))

(define (dot p q)
  (set-count (set-intersect p q)))



;; ----------------------------------------------------------------------

(define (read-notes p)
  (for/list ([l (in-lines p)])
    (parse-entry l)))

;; -> ((disp1 disp2 ...) . (disp1 disp2 ...)) 
(define (parse-entry str)
  (match-let ([`(,pattern ,output) (string-split str "|")])
    (cons
     (string-split pattern)
     (string-split output))))

;; ----------------------------------------------------------------------


(define *test* #<<EOS
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
EOS
  )

(module+ test
  (require rackunit)
  (define *entries*
    (call-with-input-string *test* read-notes))

  (check-equal? 26 (part-one *entries*))
  (check-equal? 61229 (part-two *entries*))
  )

#|

Notes
-----
            v·8 v·1 v·4 v·7 
0 : abc.efg 6   2   3   3   
1 : ..c..f. 2*  2   2   2
2 : a.cde.g 5   1   2   2
3 : a.cd.fg 5   2   3   3
4 : .bcd.f. 4*  2   4   2
5 : ab.d.fg 5   1   3   2
6 : ab.defg 6   1   3   2 
7 : a.c..f. 3*  2   2   3
8 : abcdefg 7*  2   4   3
9 : abcd.fg 6   2   4   3

a : 8
b : 6*
c : 8
d : 7
e : 4* 
f : 9*
g : 7 

|#
