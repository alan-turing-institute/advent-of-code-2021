#lang racket/base

(require racket/match
         racket/string
         racket/port
         racket/list)

(module+ main
  (define *entries* (call-with-input-file "input.txt" read-notes))

  (part-one *entries*))



(define (part-one entries)
  (define (known-digit? digit)
    (let ([n-segs (string-length digit)])
      (or (= n-segs 2)
          (= n-segs 3)
          (= n-segs 4)
          (= n-segs 7))))
  (for/sum ([note (in-list entries)])
    (count known-digit? (cdr note))))

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

  (check-equal? 26 (part-one *entries*)))



#|

Notes
-----

0 : abc.efg 6
1 : ..c..f. 2*
2 : a.cde.g 5
3 : a.cd.fg 5*
4 : .bcd.f. 4*
5 : ab.d.fg 5
6 : ab.defg 6 
7 : a.c..f. 3
8 : abcdefg 7*
9 : abcd.fg 6





|#
