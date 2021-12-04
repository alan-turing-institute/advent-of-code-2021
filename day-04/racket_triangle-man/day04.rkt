#lang racket/base

(require (only-in racket/string
                  string-split
                  non-empty-string?)
         (only-in racket/port
                  with-input-from-string)
         (only-in racket/function
                  curry)
         (only-in racket/list
                  filter-map
          ))


(module+ main
  (define p (open-input-file "input.txt"))

  ;; Part 1
  (define *draws*
    (read-draws p))
  (read-line p) 
  (define *boards*
    (map make-checkable-board (read-boards p)))

  (bingo-play/to-win *draws* *boards*) 
  (bingo-play/to-lose *draws* *boards*) 
  )


(module+ test
  (require rackunit)
  (define *input* #<<EOS
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
EOS
    )

  (define p (open-input-string *input*))
  (define *draws*
    (read-draws p))
  (read-line p)
  (define *boards*
    (map make-checkable-board (read-boards p)))

  (check-equal? (bingo-play/to-win *draws* *boards*) 4512)
  (check-equal? (bingo-play/to-lose *draws* *boards*) 1924)  
  )

;; Utilities
;; ---------

;; A (checkable) board is a pair consisting of a list of rows, followed by a list
;; of columns
(define (make-checkable-board board)
  (cons board (transpose board)))

;; Convenience accessors
(define rows-of car)
(define cols-of cdr)

(define (transpose xs)
  (apply map list xs))

(define list-sum (curry apply +))

;; Parsing
;; -------

(define (read-draws p)
  (map string->number (string-split (read-line p) ",")))

;; Return a list of all boards, each of which is a list-of-lists
(define (read-boards p)
  (let loop ([boards '()])
    (let ([board (read-board p)])
      (if (null? board)
          boards
          (loop (cons board boards))))))

;; Read a board, returning a list of rows. Assume we are at the beginning of a
;; board. If there is a blank line following the board (ie, this is not the last
;; board) it will be consumed.
(define (read-board p)
  (for/list ([row (in-lines p)])
    #:break (not (non-empty-string? row))
    (map string->number (string-split row))))


;; Bingo game play
;; ---------------

;; Repeatedly call until one board wins, returning that board
(define (bingo-play/to-win draws boards)
  (let play1 ([draws draws]
              [boards boards])
    (when (null? draws)
      (raise-user-error "Nobody won!" boards))
    (let* ([this-draw           (car draws)]
           [new-boards          (map (bingo-call this-draw) boards)]
           [maybe-winning-board (ormap bingo-check-win new-boards)])
      (if maybe-winning-board
          (score maybe-winning-board this-draw)
          (play1 (cdr draws) new-boards)))))

;; Repeatedly call until the last board wins, returning that board
(define (bingo-play/to-lose draws boards)
  (let play1 ([draws draws]
              [boards boards])
    (when (null? draws)
      (raise-user-error "Nobody won!" boards))
    (let* ([this-draw (car draws)]
           ;; This time, remove any winning boards
           [new-boards (filter (compose not bingo-check-win) (map (bingo-call this-draw) boards))])
      (if (null? new-boards) ;; Uh-oh, we just deleted the last winning board!
          (score ((bingo-call this-draw) (car boards)) this-draw) ; It must have been this one
          (play1 (cdr draws) new-boards)))))

(define (score board draw)
  (* draw (list-sum (map list-sum (rows-of board)))))

;; "Mark off" the number in a board (by removing it)
;; Return the resulting board
(define ((bingo-call draw) board)
  (cons
   (map (curry remove draw) (rows-of board))
   (map (curry remove draw) (cols-of board))))

;; Return either #f or a winning board
(define (bingo-check-win board)
  (and
   (or (ormap null? (rows-of board))
       (ormap null? (cols-of board)))
   board))

