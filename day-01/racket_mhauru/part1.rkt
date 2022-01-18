#lang racket
(define input "input")
(define v (map string->number (file->lines input)))
(length (filter identity (map < (reverse (rest (reverse v))) (rest v))))
