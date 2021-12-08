#lang racket

(require racket/set)


; --------- UTILS ---------

; ("ab" "bac") -> ((#\a #\b) (#\a #\b #\c))
(define (sort-convert-wires wires)
  (sort (string->list wires) char<?))

; list[list[str], list[str]], each line is obs-output pair. Note not actually racket Pair
; split each wire-signal string into characters and sort for easy comparison
; given each line as  "ab bac | ba cab" return "((#\a #\b) (#\a #\b #\c)  ((#\a #\b) (#\a #\b #c))"
(define (parse-input input-str) 
  (map (λ (line)
         (map (λ (line-section)
                (map (λ (wires) (sort-convert-wires wires)) line-section))
              (map string-split (string-split line "|"))))
       (string-split input-str "\n")))
  


(define (get-ind l i)
  (first (list-tail l i))
  )

; given code for 1 and unordered codes for (0 6 9) order (0 6 9)
(define (order-0-6-9 code-one code-four code-eight unordered)

  ; create set from code one and code eight
  (let ([code-one-set (list->set code-one)]
        [code-four-set (list->set code-four)]
        [code-eight-set (list->set code-eight)]
        [unordered-set (map list->set unordered)])


    ; set(1) - set(6) not empty but set(1) - set(0) and set(1) - set(9) are empty
    ; gives us 6
    (define six-ind (index-where
                     unordered-set
                     (λ (x) (equal? 1 (set-count (set-subtract code-one-set x))))
                     ))
    
    
    ; ( set(0) union set(4) ) == set(8) but ( set(9) union set(4) ) != set(8)
    ; gives us 9 (leaves 0)
    (define nine-ind (index-where
                      unordered-set
                      (λ (x) (not (equal? (set-union code-four-set x) code-eight-set)))
                      ))
    

    (define zero-ind (set-first (set-subtract (set 0 1 2) (set six-ind nine-ind))))
    
    (list (get-ind unordered zero-ind) (get-ind unordered six-ind) (get-ind unordered nine-ind))
  
    ))


; 3 and 5 confusion... 2 and 5 confusion
; given code for 1 and unordered codes for (2 3 5) order (2 3 5)
(define (order-2-3-5 code-one code-nine unordered)

  ; create set from code one and code eight
  (let ([code-one-set (list->set code-one)]
        [code-nine-set (list->set code-nine)]
        [unordered-set (map list->set unordered)])


    ; set(1) - set(3) is empty but set(1) - set(2) and set(1) - set(5) are not empty
    ; gives us 3
    (define three-ind (index-where
                       unordered-set
                       (λ (x) (set-empty? (set-subtract code-one-set x)))
                       ))
    
    
    ; length of intersection(set(9) set(5)) == 5; length of intersection(set(9) set(2)) == 4
    ; gives us 5 (leaves 2)
    (define two-ind (index-where
                     unordered-set
                     (λ (x) (equal? (set-count (set-intersect code-nine-set x)) 4))
                     ))
    

    (define five-ind (set-first (set-subtract (set 0 1 2) (set two-ind three-ind))))
    
    (list (get-ind unordered two-ind) (get-ind unordered three-ind) (get-ind unordered five-ind))
  
    ))


; map observations to numeric representation as string
(define (wire-mapping observations)

  ; group by length and sort groups by length of each member
  ; should always group into (inner order not fixed)
  ; first: length 2, (1)
  ; second: length 3 (7)
  ; third length 4, (4)
  ; fourth: length 5, (2 3 5)
  ; fifth: length 6, (0 6 9)
  ; sizth: length 7, (8)
  (define grouped (let ([grouped (group-by (lambda (xs) (length xs)) observations)])
                    (sort grouped  <
                          #:key (λ (x) (length (first x))))))

  (define mapping (make-hash))


  (define one-code (first (first grouped)))
  (define four-code (first (third grouped)))
  (define eight-code (first (sixth grouped)))

  ; add 1 7 4 8 to hash set
  (hash-set! mapping one-code "1")
  (hash-set! mapping (first (second grouped)) "7")
  (hash-set! mapping four-code "4")
  (hash-set! mapping eight-code "8")


  (define zero-six-nine (order-0-6-9 one-code four-code eight-code (fifth grouped)))
  
  (define nine-code (third zero-six-nine))
  ; add 0 6 9 to hash set
  (hash-set! mapping (first zero-six-nine) "0")
  (hash-set! mapping (second zero-six-nine) "6")
  (hash-set! mapping nine-code "9")


  (define two-three-five (order-2-3-5 one-code nine-code (fourth grouped)))
  ; add 2 3 5 to hash set
  (hash-set! mapping (first two-three-five) "2")
  (hash-set! mapping (second two-three-five) "3")
  (hash-set! mapping (third two-three-five) "5")

  
  
  mapping
  )



; --------- PARTS ---------

(define (part-one input-str)
  
  (define unique-lengths (set 2 3 4 7))
  (for/sum ([obs-output (parse-input input-str)])

    (let ([output (second obs-output)])
      (length (filter (λ (xs) (set-member? unique-lengths (length xs))) output))))
  )

(define (part-two input-str)

  (for/sum ([obs-output (parse-input input-str)])

    (let ([mapping (wire-mapping (first obs-output))])
      
      (string->number (apply string-append (for/list ([item (second obs-output)])
                                             (hash-ref mapping item)
                                             )))
      ))
  
  )

  
; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_8.txt"))
  
  (define answer-one (part-one instr))
  (display "answer 1\n")
  (display answer-one);

  (define answer-two (part-two instr))
  (display "\n\n###\n\nanswer 2\n")
  (display answer-two)
  
  )


; --------- TEST ---------

(module+ test
  (require rackunit)

  (define testin #<<EOS
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

  (check-equal? (part-one testin) 26 "Part one test")
  
  (check-equal? (part-two testin) 61229 "Part two test")


  ; test wire mapping
  ;be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb
  (define test-mapping-observations (map string->list '("acedgfb" "cdfbe" "gcdfa" "fbcad" "dab" "cefabd" "cdfgeb" "eafb" "cagedb" "ab")))


                                  
  (define table (wire-mapping test-mapping-observations))
  
  (check-equal? (hash-ref table (string->list "cagedb")) "0")
  (check-equal? (hash-ref table (string->list "ab")) "1") 
  (check-equal? (hash-ref table (string->list "gcdfa")) "2") 
  (check-equal? (hash-ref table (string->list "fbcad")) "3") 
  (check-equal? (hash-ref table (string->list "eafb")) "4")
  (check-equal? (hash-ref table (string->list "cdfbe")) "5") 
  (check-equal? (hash-ref table (string->list "cdfgeb")) "6")
  (check-equal? (hash-ref table (string->list "dab")) "7")
  (check-equal? (hash-ref table (string->list "acedgfb")) "8")
  (check-equal? (hash-ref table (string->list "cefabd")) "9")
    
  )



