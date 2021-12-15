#lang racket

; very iterative mindset tonight :(
; (after a christmas party)


;take input str and return values (template-lists (not pairs as need to match string-split output), hashtable of string insertion rules (char char)->((char char) (char char)))
(define (parse-input input-str)
  (let ([lines (string-split input-str "\n")])
    (values
     (string->list (first lines))
     (make-immutable-hash (map (λ (items)
                                 (let ([split-items (string-split items)])
                                   (let ([charpair (string->list (first split-items))]
                                         [insertion (first (string->list (third split-items)))])
                                     (cons
                                      charpair
                                      (list (list (first charpair) insertion) (list insertion (second charpair)))))))
                               (list-tail lines 2)))
     )
    ))



; convert list of chars to list of char "pairs" (not pair, list)
; "ABB" ->((#\N #\N) (#\N #\C) (#\C #\B))
(define (charlist->notpairs charlist)
  (map (λ (a b) (list a b))  (take charlist (sub1 (length charlist))) (rest charlist)))
  



(define (polymerise input-str n)
  ; initial set counts to be 1 for all initial pairs
  (let-values ([(template rules) (parse-input input-str)])
    (let ([initial-counts (make-hash (map (λ (not-pair) (cons not-pair 1)) (charlist->notpairs template)))]) 


      
      ; for each pairs in counts-i
      ;   set counts@i+1[rule[pair]] = counts@i[pair] (allowing for duplicate rule[pair] mappings)
      (let ([final-pair-counts (for/fold ([curr-pair-counts initial-counts])
                                         ([i n])

                                 (let ([new-pair-counts (make-hash)])
                                   ; loop through existing counts and set new counts
                                   (hash-for-each curr-pair-counts (λ (not-pair current-count)
                                                                     (for ([target (hash-ref rules not-pair)])
                                                                       (hash-set! new-pair-counts target (+ (hash-ref new-pair-counts target 0) current-count))
                                                                       )))
                                   new-pair-counts))])

        ; calculate char counts (will be doubled due to pairs, except first and last char)
        (let ([char-counts (make-hash)])
          (hash-for-each final-pair-counts (λ (not-pair current-pair-count)
                                             (for ([c not-pair])
                                               (let ([curr-char-count (hash-ref char-counts c 0)])
                                                 (hash-set! char-counts c (+ current-pair-count curr-char-count))))))

          ; account for first and last char
          (hash-set! char-counts (first template) (add1 (hash-ref char-counts (first template))))
          (hash-set! char-counts (last template) (add1 (hash-ref char-counts (last template))))
          (let ([count-vals (hash-values char-counts)])

            ; provide final result (div by 2)
            (/ (- (apply max count-vals) (apply min count-vals)) 2)))))))
      


    

(define (part-one input-str)
  (polymerise input-str 10))
  


(define (part-two input-str)
  (polymerise input-str 40))
    

; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_14.txt"))
  
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
NNCB

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
    )


  (check-equal? (part-one testin) 1588 "Part one test")

  (check-equal? (part-two testin) 2188189693529 "Part two test")

  )