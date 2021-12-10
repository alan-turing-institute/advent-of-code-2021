#lang racket


; define as const
(define LHS-RHS-MAP (hash  #\( #\)
                           #\[ #\]
                           #\{ #\}
                           #\< #\>))


(define (parse-input input-str)
  (map string->list (string-split input-str)))



; stack operations
(define (stack-push stack item)
  (cons item stack))

(define (stack-pop stack)
  (values (car stack) (cdr stack)))



(define (lhs stack item)
  (let ([s (stack-push stack item)])
    (values s null)))

(define (rhs stack item)
  (let-values ([(left-bracket s) (stack-pop stack)])
    ; popped item should be correct lhs for current rhs item
    (if (equal? (hash-ref LHS-RHS-MAP left-bracket) item)
        (values s null)
        ;otherwise error, set illegal item
        (values s item))))

(define (parse-line line)
  (for/fold ([stack '()]
             [illegal-item null])
            ([item line]
             #:break (not (null? illegal-item)))
    
    (if (hash-has-key? LHS-RHS-MAP item)
        ; is LHS bracket
        (lhs stack item)
          
        ; otherwise is RHS bracket, check match
        (rhs stack item)
        )
    )
  )

; return middle item from list after sorting, ignoring zeros
; can assume only positive (other than zero)
; will always be  odd number of items
(define (middle-ignore-zeros xs)
  (let ([l (sort (filter positive? xs) <)])
    (first (list-tail l (quotient (length l) 2)))))


; --------- PARTS ---------

(define (part-one input-str)

  ; points map provided by puzzle
  ; use chars
  (define points-map (hash #\) 3
                           #\] 57
                           #\} 1197
                           #\> 25137))

  (for/sum ([line (parse-input input-str)])
    (let-values ([(stack error-item) (parse-line line)])
      (hash-ref points-map error-item 0))))



  
(define (part-two input-str)

  (define points-map (hash #\( 1
                           #\[ 2
                           #\{ 3
                           #\< 4))


  (middle-ignore-zeros (for/list ([line (parse-input input-str)])
                         (let-values ([(stack last-item) (parse-line line)])
                           (if (null? last-item)
                               ; no error
                               (for/fold ([sum 0])
                                         ([lhs-item stack])
                                 (+ (* sum 5) (hash-ref points-map lhs-item))
                                 )
                               ; else
                               0
                               )))))

  
; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_10.txt"))
  
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
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
EOS
    )

  (check-equal? (part-one testin) 26397 "Part one test")
  
  (check-equal? (part-two testin) 288957 "Part two test")
  )
