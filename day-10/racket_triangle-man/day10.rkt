#lang racket/base

(require racket/string
         racket/match
         racket/port
         racket/list
         math/statistics)

(module+ main

  (define *input*
    (map string->list (call-with-input-file "input.txt" port->lines)))
  
  (part-one *input*)
  (part-two *input*))

;; ----------------------------------------------------------------------

(define (part-one lines)
  (for/sum ([line (in-list lines)])
    (let ([parse (parse-line line)])
      (if (char? parse)
          (score parse)
          0))))

(define (score token)
  (match token
    [#\)     3]
    [#\]    57]
    [#\}  1197]
    [#\> 25137]))

(define (part-two lines)
  (median <
   (filter-map
    (λ (line)
      (let ([parse (parse-line line)])
        (if (char? parse)
            #f
            (for/fold ([total 0])
                      ([token (in-list parse)])
              (+ (* total 5)
                 (score₂ token))))))
    lines)))

(define (score₂ token)
  (match token
    [#\( 1]
    [#\[ 2]
    [#\{ 3]
    [#\< 4]))

;; ----------------------------------------------------------------------

;; parse-line : [List-of char?] -> [Either char? list?]
;; Returns either:
;; - an unexpected token;
;; - a non-empty list, if the end of the line is reached before a full parse;
;; - the empty list, for a successful parse
(define (parse-line line)
  (let parse-next-token ([chars line]
                         [stack '()])
    (if (null? chars)
        stack
        (let ([token           (car chars)]
              [chars-remaining (cdr chars)])
          (cond
            [(memq token '(#\( #\[ #\{ #\<))
             (parse-next-token chars-remaining (push token stack))]
            [(memq token '(#\) #\] #\} #\>))
             (let ([stack₁ (pop/expect (match-closing token) stack)])
               (if (char? stack₁)
                   token
                   (parse-next-token chars-remaining stack₁)))]
            [else (raise-user-error 'parse-next-token "very unexpected token")])))
    ))

(define (match-closing token)
  (cdr (assq token '((#\) . #\() (#\] . #\[) (#\} . #\{) (#\> . #\<)))))

(define (push tok stack)
  (cons tok stack))

(define (pop/expect tok stack)
  (cond
    [(null? stack)               tok]
    [(not (eq? tok (car stack))) tok]
    [else                        (cdr stack)]))





;; ----------------------------------------------------------------------

(module+ test
  (require rackunit)

  (define *input* #<<EOS
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

  (define *navigation*
    (map string->list
         (string-split *input*)))

  (check-equal? 26397 (part-one *navigation*))
  (check-equal? 288957 (part-two *navigation*))

  )
