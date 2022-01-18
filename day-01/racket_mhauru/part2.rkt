#lang racket
(define input "input")
(define v (map string->number (file->lines input)))
(define (rest3 x) (rest (rest (rest x))))
(length (filter identity (map < (reverse (rest3 (reverse v))) (rest3 v))))
