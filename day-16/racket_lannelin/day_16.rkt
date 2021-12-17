#lang racket



; convert from binary to numeric
(define (gt-numeric a b)
  (if (> a b) 1 0))

; convert from binary to numeric
(define (lt-numeric a b)
  (if (< a b) 1 0))

; convert from binary to numeric
(define (equal-numeric a b)
  (if (equal? a b) 1 0))

(define TYPE-MAPPING (hash
                      0 +
                      1 *
                      2 min
                      3 max
                      5 gt-numeric
                      6 lt-numeric
                      7 equal-numeric
                      ))


(define (hexstring->binary-char-list input-str)
  ; need to leading pad as defaults to trimming leading 0s
  (let ([unpadded (string->list (format "~b" (string->number input-str 16)))]) 
    ; padding is dependent on first digit of input
    ; if 0 then "0000" and depends on second char
    ; 1-3 "00" padding, 4-7 "0" padding

    ; recursive on leading 0s
    (define (get-padding s)
      (let ([first-digit (string->number (substring s 0 1) 16)])

        (if (zero? first-digit)   
            (append '(#\0 #\0 #\0 #\0) (get-padding (substring s 1)))
            (if (< first-digit 8)
                (if (< first-digit 4)
                    '(#\0 #\0 )
                    '(#\0))
                '()))))
  
    (append (get-padding input-str) unpadded)))
    
   
            

; convert list of chars representing binary to number
(define (bincharlist->number lst)
  (if (empty? lst)
      0
      (string->number (list->string lst) 2)))


;recursive
(define (parse-literal-groups groups str-prefix)
  (let-values ([(group remaining) (split-at groups 5)])
    ; combine prefix and str repr of group (without leading bit)
    (let ([current-str (string-append str-prefix (list->string (rest group)))])
      (if (equal? #\0 (first group))
          ; last group, return converted to number with remainder
          (values (string->number current-str 2) remaining)
        
          ; not last, keep reading (recurse)
          (parse-literal-groups remaining current-str)))))


; parse all groups out of literal packet
(define (parse-literal version-num remaining-bin-chars)
  (let-values ([(val remainder-bin-chars) (parse-literal-groups remaining-bin-chars "")])
    ; return info and recurse into parse-packets for remainder
    (values val remainder-bin-chars version-num)))


; returns list of subpackets, remainder and version sum
(define (parse-subpackets-L0 bincharlist [sibling-subpackets '()] [version-sum 0])
  ; no remaining so return existing subpackets, remainder and version sum
  (if  (zero? (bincharlist->number bincharlist))
       (values  (reverse sibling-subpackets) bincharlist version-sum)
       ; otherwise call again
       (let-values ([(subpacket remaining-bincharlist packet-version) (parse-packet bincharlist)])
         (parse-subpackets-L0 remaining-bincharlist (cons subpacket sibling-subpackets) (+ version-sum packet-version)))))

  
; returns list of subpackets, remainder and version sum
(define (parse-subpackets-L1 bincharlist n [sibling-subpackets '()] [version-sum 0])
  (if  (or (zero? (bincharlist->number bincharlist)) (zero? n))
       ; no remaining so return existing subpackets, remainder and version sum
       (values (reverse sibling-subpackets) bincharlist version-sum)
       ; otherwise call again
       (let-values ([(subpacket remaining-bincharlist packet-version) (parse-packet bincharlist)])
         (parse-subpackets-L1 remaining-bincharlist (sub1 n) (cons subpacket sibling-subpackets) (+ version-sum packet-version)))))
    


(define (parse-operator version-num p-type-val remaining-bin-chars)
  (let ([operator (hash-ref TYPE-MAPPING p-type-val)])
    ; check if starts 0 or 1
    (if (equal? (first remaining-bin-chars) #\0)
        ; next 15 bits are a number that represents the total length in bits of the sub-packets contained by this packet.
        ; split into known subpackets and remainder
        (let-values ([(subpacket-len subpackets-plus-remainder)  (split-at (rest remaining-bin-chars) 15)])
          (let-values ([(subpackets-raw remaining) (split-at subpackets-plus-remainder (bincharlist->number subpacket-len))])
            (let-values ([(subpackets ignore children-version-sum) (parse-subpackets-L0 subpackets-raw)])
              
              (values (cons operator subpackets) remaining (+ version-num children-version-sum)))))
        ;otherwise next 11 bits are a number that represents the number of sub-packets immediately contained by this packet
        (let-values ([(n-subpackets subpackets-plus-remainder)  (split-at (rest remaining-bin-chars) 11)])
          (let-values ([(subpackets remaining children-version-sum) (parse-subpackets-L1 subpackets-plus-remainder (bincharlist->number n-subpackets))])
            (values (cons operator subpackets) remaining (+ version-num children-version-sum)))))))



(define (parse-packet bin-chars)
  (let-values ([(p-version after-version) (split-at bin-chars 3)])
    (let-values ([(p-type after-type) (split-at after-version 3)])
      ; is literal or operator?
      (let ([p-type-val (bincharlist->number p-type)])
        (if (equal? p-type-val 4)
            ;literal, no children
            (parse-literal (bincharlist->number p-version) after-type)
            
            ;operator
            ; check length type ID
            (parse-operator (bincharlist->number p-version) p-type-val after-type))

        ))))

(define (part-one input-str)
  (let-values ([(ignore1 ignore2 version-sum) (parse-packet (hexstring->binary-char-list input-str))])
    version-sum))


; recursive
(define (evaluate-equation inputs)
  (if (number? inputs)
      inputs
      ;else is list
      (let ([operator (first inputs)] [operands (map evaluate-equation (rest inputs))])
        (apply operator operands))))


(define (part-two input-str)
  (let-values ([(packet-result remainder version-sum) (parse-packet (hexstring->binary-char-list input-str))])
    (evaluate-equation packet-result)))
  

; --------- MAIN ---------


(module+ main
  
  (require 2htdp/batch-io)

  (define instr (read-file "input_16.txt"))
  
  (define answer-one (part-one instr))
  (display "answer 1\n")
  (display answer-one)

  (display "\n\n###\n\n")

  (define answer-two (part-two instr))
  (display "answer 2\n")
  (display answer-two)

  
  
  )


; --------- TEST ---------

(module+ test
  (require rackunit)

  ; test hexstring->binary-char-list with given conversion in instructions
  (check-equal? (hexstring->binary-char-list "38006F45291200") (string->list "00111000000000000110111101000101001010010001001000000000"))

  ; test parse-literal-groups with given conversion in instructions
  (let-values ([(lit-val remainder) (parse-literal-groups (string->list "101111111000101000") "")])
    (check-equal? lit-val 2021)
    (check-equal? remainder '(#\0 #\0 #\0)))
  
  
  ; PART ONE TESTS

  (check-equal? (part-one "8A004A801A8002F478") 16 "Part one test a")
  (check-equal? (part-one "620080001611562C8802118E34") 12 "Part one test b")
  (check-equal? (part-one "C0015000016115A2E0802F182340") 23 "Part one test c")
  (check-equal? (part-one "A0016C880162017C3686B18A3D4780") 31 "Part one test d")

  ; PART TWO TESTS

  (check-equal? (part-two "C200B40A82") 3 "Part two test a")  ; + 1 2
  (check-equal? (part-two "04005AC33890") 54 "Part two test b") ; * 6 9
  (check-equal? (part-two "880086C3E88112") 7 "Part two test c") ;  min 7 8 9
  (check-equal? (part-two "CE00C43D881120") 9 "Part two test d") ;  max 7 8 9
  (check-equal? (part-two "D8005AC2A8F0") 1 "Part two test e")
  (check-equal? (part-two "F600BC2D8F") 0 "Part two test f")
  (check-equal? (part-two "9C005AC2F8F0") 0 "Part two test g")
  (check-equal? (part-two "9C0141080250320F1802104A08") 1 "Part two test h") ; 1 + 3 = 2 * 2.



  )
