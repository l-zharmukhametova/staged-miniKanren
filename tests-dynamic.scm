(load "staged-mk.scm")

(load "staged-utils.scm")

(load "test-check.scm")

;; blurring distinction
;; between logic variable and code

;; fully now
(test (run* (q) (== 1 q)) '((1 !! ())))

;; explicitly deferred
(test (run* (q) (l== 1 q)) '((_.0 !! ((== '1 _.0)))))
(test (run* (q) (l== (cons 1 2) q))
      '((_.0 !! ((== (cons '1 '2) _.0)))))
(test (run* (q) (fresh (x) (l== (cons x x) q)))
      '((_.0 !! ((== (cons _.1 _.1) _.0)))))
(test (run* (q) (l== (list 1) (list q))) '((_.0 !! ((== (cons '1 '()) (cons _.0 '()))))))
(test (run* (q) (l== (list 1 2) (list q 3)))
      '((_.0 !! ((== (cons '1 (cons '2 '())) (cons _.0 (cons '3 '())))))))
(test (run* (q) (l== 1 2)) '((_.0 !! ((== '1 '2)))))
(test (run* (q) (fresh (p) (l== (cons p p) q) (l== p 1)))
      '((_.0 !! ((== (cons _.1 _.1) _.0) (== _.1 '1)))))
(test (run* (q) (fresh (p) (l== (cons p p) p)))
      '((_.0 !! ((== (cons _.1 _.1) _.1)))))

;; implicitly deferred
(test (run* (q) (dynamic q) (== 1 q)) '((_.0 !! ((== _.0 '1)))))
(test (run* (q) (dynamic q) (== (list 1) (list q))) '((_.0 !! ((== _.0 '1)))))
(test (run* (q) (dynamic q) (== (list 1 2) (list q 3))) '())
(test (run* (q) (fresh (p) (dynamic p) (== (cons p p) q)))
      '(((_.0 . _.0) !! ())))
(test (run* (q) (fresh (p) (dynamic p) (== (cons q q) p)))
      '((_.0 !! ((== _.1 (cons _.0 _.0))))))
(test (run* (q) (fresh (p) (dynamic p) (== (cons p p) p)))
      '()) ;; cool!
(test (run* (q) (fresh (p) (dynamic q p) (== (cons p p) q)))
      '((_.0 !! ((== _.0 (cons _.1 _.1))))))
(test (run* (q) (fresh (p) (dynamic q p) (== (cons q q) q)))
      '())
(test (run* (q) (fresh (p) (== q (cons p p)) (== q p)))
      '())
(test (run* (q) (fresh (p) (dynamic q) (== q (cons p p)) (== q p)))
      '((_.0 !! ((== _.0 (cons _.1 _.1)) (== _.0 _.1))))) ;; not as cool
(test (run* (q) (fresh (p) (dynamic q) (== q p) (== q (cons p p))))
      '((_.0 !! ((== _.0 _.1) (== _.0 (cons _.1 _.1)))))) ;; ditto
(test (run* (q) (fresh (p) (dynamic p) (== q (cons p p)) (== q p)))
      '()) ;; cool
(test (run* (q) (fresh (p) (dynamic p) (== q p) (== q (cons p p))))
      '(((_.0 . _.0) !! ((== (cons _.0 _.0) _.0)))))

;; what to do about constraints?
(test (run* (q) (dynamic q) (=/= 1 q))
      '(((_.0 !! ((=/= _.0 '1))) (=/= ((_.0 1)))))) ;;wrong: asymmetry with unification?

;; staging with vanilla interp!
(load "full-interp.scm")
(test (run* (q) (dynamic q) (eval-expo 1 '() q))
      '((_.0 !! ((== _.0 '1)))))

(test (run 1 (q)
           (fresh (arg res) (== q (list arg res))
                  (eval-expo 'x `((x . (val . ,arg))) res)))
      '(((_.0 _.0) !! ())))

(test (run 1 (q)
           (fresh (arg res)
                  (dynamic arg res)
                  (== q (list arg res))
                  (eval-expo 'x `((x . (val . ,arg))) res)))
      '(((_.0 _.1) !! ((== _.1 _.0)))))

;; The examples with if show that each branch is grounded
;; into an answer.

(test
 (run 1 (q)
      (fresh (arg res env)
             (dynamic arg res)
             (== q (list arg res))
             (ext-env*o '(x) `(,arg) initial-env env)
             (eval-expo '(if (null? '()) 1 2) env res)))
 '(((_.0 _.1) !! ((== _.2 _.0) (== _.1 '1)))))

(test
 (run* (q)
       (fresh (arg res env)
              (== q (list arg res))
              (ext-env*o '(x) `(,arg) initial-env env)
              (eval-expo '(if (null? x) 1 2) env res)))
 '(((() 1) !! ()) (((_.0 2) !! ()) (=/= ((_.0 ()))))))

(test
 (run* (q)
       (fresh (arg res env)
              (dynamic arg res)
              (== q (list arg res))
              (ext-env*o '(x) `(,arg) initial-env env)
              (eval-expo '(if (null? x) 1 2) env res)))
'(((_.0 _.1) !! ((== '() _.0) (== _.1 '1)))
  (((_.0 _.1) !! ((== _.2 _.0) (== _.1 '2)))
   (=/= ((_.2 ()))))))


;; The if-grounding means that for a recursive relation,
;; we ground on the recursive structure...
;; This is not symbolic enough, it's suggestive
;; of limitations SMT has with recursion.
(test
 (run 2 (q)
      (fresh (xs ys res env)
             (dynamic xs ys)
             (== q (list xs ys res))
             (ext-env*o '(xs ys) (list xs ys) initial-env env)
             (eval-expo `(letrec
                             ((append (lambda (xs ys)
                                        (if (null? xs) ys
                                            (cons (car xs)
                                                  (append (cdr xs) ys))))))
                           (append xs ys))
                        env
                        res)))

 '(((_.0 _.1 _.2) !! ((== '() _.0) (== _.2 _.1)))
   (((_.0 _.1 (_.2 . _.3))
     !!
     ((== (cons _.2 '()) _.0) (== _.3 _.1)))
    (=/= ((_.2 closure))))))

;; next step
;; what is an alternative to semantics to if-grounding for dynamic variables?

(test
 (run* (r)
      (fresh (q t)
             (dynamic q t)
             (== r (list q t))
             (lconde
              ((=/= #f t) (== q 1))
              ((== #f t) (== q 2)))))
 '(((_.0 _.1)
   !!
   ((conde
      ((=/= _.1 '#f) (== _.0 '1))
      ((== _.1 '#f) (== _.0 '2)))))))

(test
 (run* (r)
      (fresh (q t)
             (dynamic q)
             (== r (list q t))
             (lconde
              ((=/= #f t) (== q 1))
              ((== #f t) (== q 2)))))
 '(((_.0 _.1) !! ((conde ((== _.0 '1)) ((== _.0 '2)))))))


;; here is one alternative:
(load "dynamic-interp.scm")
(define appendo
  (eval
   (gen 'append '(xs ys)
        '(if (null? xs) ys
             (cons (car xs)
                   (append (cdr xs) ys))))))
(test
 (run* (q) (fresh (x y)
                 (== q (list x y))
                 (dynamic x)
                 (== 1 x)
                 (== x 6)))
 '(((_.0 _.1) !! ((== _.0 '1) (== _.0 '6)))))

(test 
 (run* (q) (fresh (x y)
                 (== q (list x y))
                 (== x y)
                 (dynamic x)
                 (== y 5)
                 (== y 6)))
 '())

(test 
 (run* (q) (fresh (x y)
                 (== q (list x y))
                 (== y x)
                 (dynamic x)
                 (== y 5)
                 (== y 6)))
 '(((_.0 _.0) !! ((== _.0 '5) (== _.0 '6)))))

(test 
 (run* (q) (fresh (x y)
                 (== q (list x y))
                 (dynamic x)
                 (== y 5)
                 (== x y)
                 (== y 6)))
 '())

(test
 (run* (q) (fresh (x y)
                 (== q (list x y))
                 (dynamic x)
                 (== y 5)
                 (== y 6)
                 (== x y)))
 '())

(test
 (run* (q) (appendo '(a) '(b) q))
 '(((a b) !! ())))
(test
 (run* (q) (appendo q '(b) '(a b)))
 '(((a) !! ())))
(test
 (run* (q) (fresh (x y) (== q (list x y)) (appendo x y '(a b c d e))))
 '(((() (a b c d e)) !! ())
   (((a) (b c d e)) !! ())
   (((a b) (c d e)) !! ())
   (((a b c) (d e)) !! ())
   (((a b c d) (e)) !! ())
   (((a b c d e) ()) !! ())))
