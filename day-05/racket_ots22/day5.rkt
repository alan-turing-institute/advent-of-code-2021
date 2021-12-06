#lang racket

(struct line (x0 y0 x1 y1))

;; Step through [start, end], with a step size depending on the sign
;; of end - start. Step size of zero means repeat forever (presumably
;; the *other* coordinate doesn't!)
(define (in-coord start end)
  (define step (sgn (- end start)))
  (in-inclusive-range start end step))

(define (line->points l)
  (sequence->list
   (sequence-map list (in-parallel (in-coord (line-x0 l) (line-x1 l))
                                   (in-coord (line-y0 l) (line-y1 l))))))

(define (count-overlapping lines)
  (count (λ (grp) (>= (length grp) 2))
         (group-by values (append-map line->points lines))))

(define (part1 lines)
  (count-overlapping
   (filter (λ (l) (or (= (line-x0 l) (line-x1 l))
                      (= (line-y0 l) (line-y1 l))))
           lines)))

(define part2 count-overlapping)

(define (parse-line str)
  (define pattern #rx"([0-9]*),([0-9]*) -> ([0-9]*),([0-9]*)")
  (define regexp-group-matches (cdr (regexp-match pattern str)))
  (apply line (map string->number regexp-group-matches)))

(define (read-input) (map parse-line (port->lines)))

(module+ test
  (require rackunit)
  (define test-input (with-input-from-file "test.in" read-input))
  (check-equal? (part1 test-input) 5)
  (check-equal? (part2 test-input) 12))

(module+ main
  (define input (with-input-from-file "5.in" read-input))
  (part1 input)
  (part2 input))
