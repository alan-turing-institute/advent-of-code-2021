#lang racket

(require graph)

(module+ main
  
  (define *graph*
    (call-with-input-string #<<EOS
LP-cb
PK-yk
bf-end
PK-my
end-cb
BN-yk
cd-yk
cb-lj
yk-bf
bf-lj
BN-bf
PK-cb
end-BN
my-start
LP-yk
PK-bf
my-BN
start-PK
yk-EP
lj-BN
lj-start
my-lj
bf-LP
EOS
                            read-caves))

  ;; Part one
  (length (all-paths *graph* "start" "end" '()))

  ;; Part two
  (length (remove-duplicates ;; Ugh.
           (all-paths/2 *graph* "start" "end" '() #f)))

  )


;; Breadth-first search from here to end
(define (all-paths G here end visited)
  (if (equal? here end)
      (list end)
      (let ([visited* (if (small-cave? here) (cons here visited) visited)])
        (map (curry cons here)
             (append*
              (for/list ([v (in-neighbors G here)]
                         #:unless (member v visited*))
                (all-paths G v end visited*)))))))

;; Breadth-first search from here to end, small caves at most once, except for one
(define (all-paths/2 G here end visited twice?)
  (if (equal? here end)
      (list end)
      (let ([visited* (if (small-cave? here) (cons here visited) visited)])
        (map (curry cons here)
             (if (or twice? (equal? here "start"))
                 (append* ;; Either we've had the chance, or we're on "start"
                  (for/list ([v (in-neighbors G here)]
                             #:unless (member v visited*))
                    (all-paths/2 G v end visited* twice?)))
                 (append ; twice? is false
                  (append* ;; Don't delete here but set twice?
                   (for/list ([v (in-neighbors G here)]
                              #:unless (member v visited))
                     (all-paths/2 G v end visited #t)))
                  (append* ;; Delete here and don't set twice
                   (for/list ([v (in-neighbors G here)]
                              #:unless (member v visited*))
                     (all-paths/2 G v end visited* twice?))
                   ))
                 )))))


;; I mean, I really ought to precompute this ...
(define (small-cave? cave)
  (andmap char-lower-case? (string->list cave)))

;; ----------------------------------------------------------------------
;; Parsing

(define (read-caves p)
  (let* ([edges (map (curryr string-split "-") (port->lines p))])
    (undirected-graph edges)))


;; ----------------------------------------------------------------------
;; Testing

(module+ test
  (require rackunit)

  (define *small-graph*
    (call-with-input-string #<<EOS
start-A
start-b
A-c
A-b
b-d
A-end
b-end
EOS
                            read-caves))
  
  (define *big-graph*
    (call-with-input-string #<<EOS
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
EOS
                            read-caves))

  (check-equal? (length (all-paths *big-graph* "start" "end" '()))
                226)
  
  (check-equal? (length (remove-duplicates
                         (all-paths/2 *small-graph* "start" "end" '() #f)))
                36)

    (check-equal? (length (remove-duplicates
                         (all-paths/2 *big-graph* "start" "end" '() #f)))
                3509)

  )
