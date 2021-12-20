#lang typed/racket

; for better type inference on map
(require typed-map)


; max steps to brute force
(define MAX-STEPS : Integer  1000)

; parse coord part of input e.g. "x=20..30", use list as native output of string split
(: parse-coord-part (-> String (Listof Integer)))
(define (parse-coord-part part)
  (let ([coords-string : String (second (string-split part "="))])
    ; deal with Number vs Integer with a cast - this is brittle but will work for our inputs
    (map (λ (v) (cast (string->number v) Integer)) (string-split coords-string ".."))))

; parse input and return target area
(: parse-input (-> String (Pairof (Listof Integer) (Listof Integer))))
(define (parse-input input-str)
  (let ([space-delimited : (Listof String) (string-split input-str)])
    ; get x part and y part, removing trailing comma from x-part
    (let ([x-part : String (string-replace (third space-delimited) "," "")] [y-part : String (fourth space-delimited)])
      (cons (parse-coord-part x-part) (parse-coord-part y-part)))))


(: triangle (-> Integer Integer))
(define (triangle x)
  ; cast :(
  (cast (/ (* x (add1 x)) 2) Integer))


(: inside-area? (-> Integer Integer Integer Nonnegative-Integer Integer Integer Boolean))
(define (inside-area? x y x-min x-max y-min y-max)
  (and (and (>= x x-min) (<= x x-max)) (and (<= y y-max) (>= y y-min))))

; only accept positive x and x-max
(: hits-target? (-> Nonnegative-Integer Integer Integer Nonnegative-Integer Integer Integer Boolean))
(define (hits-target? initial-x initial-y x-min x-max y-min y-max)
  
  (let-values ([(hit final-x final-y final-vel-x final-vel-y)
                (for/fold ([hit : Boolean #f] [last-x : Integer 0] [last-y : Integer 0] [last-vel-x : Nonnegative-Integer initial-x] [last-vel-y : Integer initial-y])
                          ([i : Nonnegative-Integer MAX-STEPS]
                           #:break (or hit (or (> last-x x-max) (< last-y y-min)))) ; break if theres a hit or if gone past
                  (let ([x (+ last-x last-vel-x)]
                        [y (+ last-y last-vel-y)]
                        [vel-x (max 0 (sub1 last-vel-x))]
                        [vel-y (sub1 last-vel-y)])
                   

                  (values (inside-area? x y  x-min x-max y-min y-max)  x y vel-x vel-y)))])
   
    hit))


; brute force 0-max-x 0-max-y
(: n-distinct-velocities (-> Integer Integer Integer Integer Integer))
(define (n-distinct-velocities x-min x-max y-min y-max)
  
  ; loop through all x values, then all y values
  ; simplify by flipping x if max-x is negative
  (if (negative? x-max)
      (n-distinct-velocities (- 0 x-min) (- 0 x-max) y-min y-max)
      ;otherwise loop through xs 0 to max-x
      (for/sum : Integer ([x : Nonnegative-Integer (add1 x-max)]
                          #:when (> (triangle x) x-min)) ; check if wont' reach)


        (for/sum : Integer ([y : Integer (in-range y-min (abs y-min))])
          (if (hits-target? x y x-min x-max y-min y-max)
              1
              0)))))
                         
  

;find highest y reachable while still hitting the target
; assumption that y cannot be positive
; assume that valid x can be found for any positive y
(: part-one (-> String Integer))
(define (part-one input-str)
  (let ([target-area : (Pairof(Listof Integer) (Listof Integer)) (parse-input input-str)])
    (let ([x-min : Integer (first (car target-area))] [x-max : Integer (second (car target-area))] [y-min : Integer (first (cdr target-area))] [y-max : Integer (second (cdr target-area))])
      (triangle (sub1 (abs y-min)))
      )))


; how many distinct velocity values  for given target area?
; assumption that y cannot be positive
(: part-two (-> String Integer))
(define (part-two input-str)
  (let ([target-area : (Pairof(Listof Integer) (Listof Integer)) (parse-input input-str)])
    (let ([x-min : Integer (first (car target-area))] [x-max : Integer (second (car target-area))] [y-min : Integer (first (cdr target-area))] [y-max : Integer (second (cdr target-area))])
      (n-distinct-velocities x-min x-max y-min y-max))))
      

; --------- MAIN ---------


(module+ main

  (require racket/port)

  (define input : String (with-input-from-file "input_17.txt" port->string))

  
  (define answer-one : Integer (part-one input))
  (display "answer 1\n")
  (display answer-one)

  (display "\n\n###\n\n")

  (define answer-two (part-two input))
  (display "answer 2\n")
  (display answer-two)

  
  
  )


; --------- TEST ---------

(module+ test
  (require typed/rackunit)


  (define testin : String "target area: x=20..30, y=-10..-5")
  
  (check-equal? (parse-input testin) (cons '(20 30) '(-10 -5)))

  ; PART ONE TESTS

  (check-equal? (part-one testin) 45 "Part one test")
  
  ; PART TWO TESTS

  (check-equal? (part-two testin) 112 "Part two test") 
  
  )




