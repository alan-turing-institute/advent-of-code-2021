#lang racket

(require math/array)

(define (sum xs) (for/sum ([x xs]) x))

(define (min-by f xs less-than)
  (for/fold ([argmin (car x)]
             [min (f (car x))])
            ([x (cdr xs)])
    (let ([y (f x)])
      (if (less-than y min)
          (values x y)
          (values argmin min)))))

;; On which draw does 'card' win, when the numbers drawn are 0,1,2...?
(define (card-winning-draw card)
  (apply min (append (array->list (array-axis-max card 0))
                     (array->list (array-axis-max card 1)))))

(define (solve-it numbers cards)
  (define (number->draw n) (index-of numbers n))
  (define (draw->number d) (list-ref numbers d))

  ;; Re-number each card, so that the numbers are drawn as 0,1,2,...
  (define cards* (map (curry array-map number->draw) cards))

  ;; The score of card* (numbered as above), at the given draw
  (define (score card* draw)
    (let ([number (draw->number draw)]
          [remaining-numbers
           (map draw->number (filter (curryr > draw) (array->list card*)))])
      (* number (sum remaining-numbers))))

  ;; Score of the winning card
  (define part1 (call-with-values (λ () (min-by card-winning-draw cards* <))
                                  score))
  ;; Score of the losing card
  (define part2 (call-with-values (λ () (min-by card-winning-draw cards* >))
                                  score))
  (values part1 part2))

(define (read-input)
  (define numbers (map string->number (string-split (read-line) ",")))

  (read-line) ; blank

  ;; A list of rank-2 arrays, each representing a bingo card
  (define cards (for/list ([card (string-split (port->string) "\n\n")])
                  (array-list->array
                   (for/list ([row (string-split card "\n")])
                     (for/array ([num-str (string-split row)])
                       (string->number num-str))))))
  (values numbers cards))


(module+ test
  (require rackunit)

  (define-values (numbers cards) (with-input-from-file "test.in" read-input))
  (define-values (part1 part2) (solve-it numbers cards))

  (check-equal? part1 4512)
  (check-equal? part2 1924))

(module+ main
  (define-values (numbers cards) (with-input-from-file "4.in" read-input))
  (solve-it numbers cards))
