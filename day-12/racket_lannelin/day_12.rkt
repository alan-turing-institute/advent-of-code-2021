#lang racket

; I'm not proud of this one :(


; install with `raco pkg install --auto graph`
(require data/queue
         graph)

; parse input of multiline str. Lines of form "a-b" as graph edge between a and b
(define (parse-input input-str)
  (map (λ (edge-str) (string-split edge-str "-")) (string-split input-str)))


(define (is-small? cave)
  (not (equal? (string-upcase cave) cave)))



(define (n-paths G src dest max-visits-getter)
  
  ; used for checking only small caves that aren't start and end
  (define small-not-start-end (filter (λ (v) (and (is-small? v) (not (or (equal? v "start") (equal? v "end")))))  (get-vertices G)))
  
  ; recursive
  (define (n-paths-fn G start end n-visits acc)

    ; wrap in a let to allow reset of hash set for current startt key
    (let ([extras
           (if (equal? start end)
               ; add one
               1
               ;else add sum of all possible further paths
               (for/sum ([v (in-neighbors G start)]
                         ; be picky about "seen" nodes
                         #:when  (and                                               
                                  ; less than max visits to v
                                  (< (hash-ref n-visits v 0) (max-visits-getter v))
                                  ; v is not small cave set to 1 when any other small cave is 2 (part 2)
                                  (not (and (is-small? v)
                                            (and  (equal? (hash-ref n-visits v 0) 1)
                                                  (< 1  (apply max (map (λ (small-cave) (hash-ref n-visits small-cave 0)) small-not-start-end))))))))
                              
                               (displayln (list "start: " start "v: " v "n visits: " n-visits)
                 (n-paths-fn G v end (hash-set n-visits start (add1 (hash-ref n-visits start 0))) acc)))])
      
      ; reset hash set for start
      ;(hash-set! n-visits start (sub1 (hash-ref n-visits start)))
      ; return acc + extras
      (+ acc extras)            
      ))

  (n-paths-fn G src dest (make-immutable-hash) 0))


; PART ONE
(define (part-one input-str)
  (let ([G (unweighted-graph/undirected (parse-input input-str))])
    (define-vertex-property G max-visits #:init 1)
    ; construct a mapping of max visits per node
    (for ([v (get-vertices G)])
      (max-visits-set! v 
                       (let ([small (is-small? v)])
                         (cond
                           [(equal? "start" v) 1]
                           [(equal? "end" v) 1]
                           [small 1]
                           [else +inf.0])))
      )
  
    (n-paths G "start" "end" max-visits))
  )



; PART TWO
; the same but uses a different max-visits mapping and required a slight alteration to n-paths

(define (part-two input-str)
  (let ([G (unweighted-graph/undirected (parse-input input-str))])
    (define-vertex-property G max-visits #:init 1)
    (for ([v (get-vertices G)])
      ; construct a mapping of max visits per node
      (max-visits-set! v 
                       (let ([small (is-small? v)])
                         (cond
                           [(equal? "start" v) 1]
                           [(equal? "end" v) 1]
                           [small 2]
                           [else +inf.0])))
      ) 
  
    (n-paths G "start" "end" max-visits))
  )


; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_12.txt"))
  
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

  (define testin-a #<<EOS
start-A
start-b
A-c
A-b
b-d
A-end
b-end
EOS
    )

  (define testin-b #<<EOS
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc
EOS
    )

  

  (check-equal? (part-one testin-a) 10 "Part one test a")
  (check-equal? (part-one testin-b) 19 "Part one test b")

    
  (check-equal? (part-two testin-a) 36 "Part two test")
  (check-equal? (part-two testin-b) 103 "Part two test")
  )




