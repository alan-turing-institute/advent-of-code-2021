#lang racket


(define (flatten-single-level lsts)
  (foldl (λ (right left)
           (append left right))
         '()
         lsts))


(define (parse-coords coords)
  (map string->number (string-split coords ","))
  )


(define (horizontal-vertical x1 x2 y1 y2)
  (or (equal? x1 x2) (equal? y1 y2)))

(define (horizontal-vertical-diagonal x1 x2 y1 y2)
  (or
   (equal? x1 x2)
   (or
    (equal? y1 y2)
    (equal? (abs (- y2 y1)) (abs(- x2 x1))))
   )
  )

; repeat element e l times
(define (tile e l)
  (if (equal? l 1)
      (cons e '())
      (cons e (tile e (- l 1)))))

; expect input of form ((x1 y1) (x2 y2))
; output taxi interpolation (traverse x then y)
; e.g. input ((1 3) (1 4)) -> ((1 3) (1 4))
; only allows horizontal and vertical lines
; filter fn should take x1 x2 y1 y2 args
(define (expand-coords start-end-coords filter-fn)

  
  (define start (car start-end-coords))
  (define end (cdr start-end-coords))

  ; order for in-range must be lower,higher so allow x1 x2 to reverse
  ; same for y
  (define x1 (first start))
  (define x2 (first end))

  (define y1 (second start))
  (define y2 (second end))

  (define x-step (if (>= x2 x1) 1 -1 ))
  (define y-step (if (>= y2 y1) 1 -1 ))

  
  (define ret (if (filter-fn x1 x2 y1 y2)
                  ; if allowed sequence (e.g. horizontal)
                  (for/list
                      ; make sure x and y range are same length
                      ([x (if (equal? x1 x2)
                              (tile x1 (+ (abs (- y2 y1)) 1))
                              (in-range x1 (+ x2 x-step) x-step))]
                       [y (if (equal? y1 y2)
                              (tile y1 (+ (abs (- x2 x1)) 1))
                              (in-range y1 (+ y2 y-step) y-step))])
                    (list x y))
                  '()))

  
  (identity ret)
  )


; expect input of form (("x1,y1" "-> "x2,y2")...)
; return list[pair[list,list]] form (((x1 y1) (x2 y2)) ... ) 
(define (parse-input input-list filter-fn)
  (map (λ (line) (expand-coords (cons (parse-coords (first line)) (parse-coords (third line))) filter-fn)) input-list)
  )


; expect input of form (("x1,y1" "-> "x2,y2")...) anf filter fn that takes (x1 x2 y1 y2)
(define (calc-overlap input-list filter-fn)
  (define coords (flatten-single-level (parse-input input-list filter-fn)))

  
  (define-values (overlaps seen) (for/fold ([dupes 0]
                                            [myhash (make-immutable-hash)])
                                           ([coord coords])



                                   ; check whether existting value is 1 (doesn't matter if 0 or > 1)
                                   (if (equal? (hash-ref myhash coord 0) 1)
                                       ; if 1, return original set with duplicates incremented and updated hashtable
                                       (values (+ dupes 1) (hash-update myhash coord add1 0))
                                       ; otherwise return updated hashtable only
                                       (values dupes (hash-update myhash coord add1 0))
                                       )
                                   )
    )
                                

  (identity overlaps)
  )

; expect input of form (("x1,y1" "-> "x2,y2")...)
(define (part-one input-list)
  (calc-overlap input-list  horizontal-vertical)
  
  )

; expect input of form (("x1,y1" "-> "x2,y2")...)
(define (part-two input-list)
  (calc-overlap input-list  horizontal-vertical-diagonal)
  
  )


; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)
  
  
  (define inlines (read-words/line "input_5.txt"))

  (define answer-one (part-one inlines))
  (display "answer 1\n")
  (display answer-one)

  (define answer-two (part-two inlines))
  (display "\n\n###\n\nanswer 2\n")
  (display answer-two)
  
  )


; --------- TEST ---------

(module+ test
  (require rackunit)

  (define testin '(("0,9" "->" "5,9") 
                   ("8,0" "->" "0,8")
                   ("9,4" "->" "3,4")
                   ("2,2" "->" "2,1")
                   ("7,0" "->" "7,4")
                   ("6,4" "->" "2,0")
                   ("0,9" "->" "2,9")
                   ("3,4" "->" "1,4")
                   ("0,0" "->" "8,8")
                   ("5,5" "->" "8,2") 
                   ))

  (check-equal? (part-one testin) 5 "Part one test")
  
  (check-equal? (part-two testin) 12 "Part two test")
  )

