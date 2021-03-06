;; using namin/faster-miniKaren branch staged
(load "../faster-miniKanren/mk-vicare.scm")
(load "../faster-miniKanren/mk.scm")

(load "staged-interp.scm")
(load "staged-utils.scm")

(load "test-check.scm")

(test (ex 't '(x) 'x) '(x))
(test
 (gen 't '(x) 'x)
 '(lambda (x out)
    (fresh
     (_.0)
     (== _.0 out)
     (letrec ([t (lambda (x)
                   (lambda (_.1) (fresh () (== x _.1))))])
       (fresh (_.2) (== x _.2) ((t _.2) _.0))))))
(define ido (eval (gen 't '(x) 'x)))
(test (run* (q) (ido q q)) '(_.0))

(test (ex 't '(x) '((lambda (y) y) x)) '(x))
(test
 (gen 't '(x) '((lambda (y) y) x))
 '(lambda (x out)
    (fresh
     (_.0)
     (== _.0 out)
     (letrec ([t (lambda (x)
                   (lambda (_.1) (fresh (_.2) (== x _.2) (== _.2 _.1))))])
       (fresh (_.3) (== x _.3) ((t _.3) _.0))))))
(test (ex 't '(x) '(((lambda (y) (lambda (z) z)) x) x)) '(x))
(test (ex 't '(x) '(((lambda (y) (lambda (z) z)) 5) x)) '(x))

(test (ex 't '(x) '5) '(5))
(test (gen 't '(x) '5)
      '(lambda (x out)
         (fresh
          (_.0)
          (== _.0 out)
          (letrec ([t (lambda (x)
                        (lambda (_.1) (fresh () (== '5 _.1))))])
            (fresh (_.2) (== x _.2) ((t _.2) _.0))))))
(test (ex 't '(x) '((lambda (y) y) 5)) '(5))
(test (ex 't '(x) '(((lambda (y) (lambda (z) z)) x) 5)) '(5))

(test (ex 't '(x) '(if #t x 5)) '(x))

(test (ex 't '(x) '(letrec ((f (lambda (y) y))) 1)) '(1))

(test (ex 't '(x) '(letrec ((f (lambda (y) y))) (f x))) '(x))

(test (ex 't '(x) '(letrec ((f (lambda (y) (cons y y)))) (f x))) '((x . x)))

(test ((fwd1 (eval (gen 't '(x) '(null? x)))) '()) '(#t))
(test ((fwd1 (eval (gen 't '(x) '(null? x)))) '(a b)) '(#f))

(test ((fwd1 (eval (gen 'f '(x) '(letrec ((f (lambda (y) (if (null? y) '() (cdr y))))) (f x))))) '()) '(()))
(test ((fwd1 (eval (gen 'f '(x) '(letrec ((f (lambda (y) (if (null? y) '() (cdr y))))) (f x))))) '(a b)) '((b)))

(test (ex 'f '(x) '(letrec ((f (lambda (y) (if (null? y) '() (f (cdr y)))))) (f x))) '())
(test
 (gen 'f '(x) '(letrec ((f (lambda (y) (if (null? y) '() (f (cdr y)))))) (f x)))
 '(lambda (x out)
  (fresh
    (_.0)
    (== _.0 out)
    (letrec ([f (lambda (x)
                  (lambda (_.1)
                    (fresh
                      ()
                      (letrec ([f (lambda (y)
                                    (lambda (_.2)
                                      (fresh (_.3 _.4 _.5 _.6 _.8 _.7)
                                        (== (cons _.3 '()) (cons _.4 '()))
                                        (conde
                                          ((== '() _.3) (== #t _.5))
                                          ((=/= '() _.3) (== #f _.5)))
                                        (== y _.4)
                                        (conde
                                          ((=/= #f _.5) (== _.2 '()))
                                          ((== #f _.5)
                                            (== (cons (cons _.6 _.7) '())
                                                (cons _.8 '()))
                                            (== y _.8)
                                            ((f _.7) _.2))))))])
                        (fresh (_.9) (== x _.9) ((f _.9) _.1))))))])
      (fresh (_.10) (== x _.10) ((f _.10) _.0))))))

(test (ex 't '(x) '(letrec ((f (lambda (y) (if (null? y) '() (cons 1 (f (cdr y))))))) (f x))) '())
(test
 (gen 't '(x) '(letrec ((f (lambda (y) (if (null? y) '() (cons 1 (f (cdr y))))))) (f x)))
 ' (lambda (x out)
  (fresh
    (_.0)
    (== _.0 out)
    (letrec ([t (lambda (x)
                  (lambda (_.1)
                    (fresh
                      ()
                      (letrec ([f (lambda (y)
                                    (lambda (_.2)
                                      (fresh
                                        (_.3 _.4 _.5 _.6 _.7 _.8 _.10 _.12
                                             _.9 _.11)
                                        (== (cons _.3 '()) (cons _.4 '()))
                                        (conde
                                          ((== '() _.3) (== #t _.5))
                                          ((=/= '() _.3) (== #f _.5)))
                                        (== y _.4)
                                        (conde
                                          ((=/= #f _.5) (== _.2 '()))
                                          ((== #f _.5)
                                            (== (cons _.6 (cons _.7 '()))
                                                (cons _.8 (cons _.9 '())))
                                            (== (cons _.6 _.7) _.2)
                                            (== '1 _.8)
                                            (== (cons (cons _.10 _.11) '())
                                                (cons _.12 '()))
                                            (== y _.12)
                                            ((f _.11) _.9))))))])
                        (fresh (_.13) (== x _.13) ((f _.13) _.1))))))])
      (fresh (_.14) (== x _.14) ((t _.14) _.0))))))
(test ((fwd1 (eval (gen 't '(x) '(letrec ((f (lambda (y) (if (null? y) '() (cons 1 (f (cdr y))))))) (f x))))) '(a b)) '((1 1)))

(test (ex 't '(x) ''(a b c)) '((a b c)))
(test
 (gen 't '(x) ''(a b c))
 '(lambda (x out)
  (fresh
    (_.0)
    (== _.0 out)
    (letrec ([t (lambda (x)
                  (lambda (_.1)
                    (fresh
                      ()
                      (== _.1 (cons 'a (cons 'b (cons 'c '())))))))])
      (fresh (_.2) (== x _.2) ((t _.2) _.0))))))

(define appendo
  (eval
   (gen 'append '(xs ys)
        '(if (null? xs) ys
             (cons (car xs)
                   (append (cdr xs) ys))))))

(test (run* (q) (appendo '(a) '(b) q)) '((a b)))
(test (run* (q) (appendo q '(b) '(a b))) '((a)))
(test
 (run* (q) (fresh (x y) (== q (list x y)) (appendo x y '(a b c d e))))
 '((() (a b c d e)) ((a) (b c d e)) ((a b) (c d e))
  ((a b c) (d e)) ((a b c d) (e)) ((a b c d e) ())))

(test
 (gen 'ex-if '(x) '(if (null? x) 1 2))
 '(lambda (x out)
  (fresh
    (_.0)
    (== _.0 out)
    (letrec ([ex-if (lambda (x)
                      (lambda (_.1)
                        (fresh (_.2 _.3 _.4) (== (cons _.2 '()) (cons _.3 '()))
                          (conde
                            ((== '() _.2) (== #t _.4))
                            ((=/= '() _.2) (== #f _.4)))
                          (== x _.3)
                          (conde
                            ((=/= #f _.4) (== '1 _.1))
                            ((== #f _.4) (== '2 _.1))))))])
      (fresh (_.5) (== x _.5) ((ex-if _.5) _.0))))))
(test (run* (q) (l== q 1) (l== q 2))
      '((_.0 !! ((== _.0 2) (== _.0 1)))))
(test (run* (q) (conde [(l== q 1)] [(l== q 2)]))
      '((_.0 !! ((== _.0 1))) (_.0 !! ((== _.0 2)))))
(test (run* (q) (lift `(conde [(== ,q 1)] [(== ,q 2)])))
      '((_.0 !! ((conde ((== _.0 1)) ((== _.0 2)))))))
(define fake-evalo (lambda (q n)
                     (fresh ()
                       (l== q n)
                       (l== n n))))
(test
 (run* (q)
       (fresh (c1 c2)
              (lift-scope (fake-evalo q 1) c1)
              (lift-scope (fake-evalo q 2) c2)
              (lift `(conde ,c1 ,c2))))
 '((_.0 !!
        ((conde
          ((== _.0 '1) (== '1 '1))
          ((== _.0 '2) (== '2 '2)))))))

;; beyond appendo
;; challenge 6 of ICFP'17
(define member?o
  (eval (gen 'member? '(x ls)
             '(if (null? ls) #f
                  (if (equal? (car ls) x) #t
                      (member? x (cdr ls)))))))
(test (run* (q) (member?o 'A '(A) q)) '(#t))
(test (run* (q) (member?o 'A '(B) q)) '(#f))
(test (run* (q) (fresh (a b) (== q (list a b)) (member?o a '() b))) '((_.0 #f)))
(define proof?o
  (eval (gen 'proof? '(proof)
             '(match proof
                [`(,A ,assms assumption ()) (member? A assms)]
                [`(,B ,assms modus-ponens
                      (((,A => ,B) ,assms ,r1 ,ants1)
                       (,A ,assms ,r2 ,ants2)))
                 (and (proof? (list (list A '=> B) assms r1 ants1))
                      (proof? (list A assms r2 ants2)))]
                [`((,A => ,B) ,assms conditional
                   ((,B (,A . ,assms) ,rule ,ants)))
                 (proof? (list B (cons A assms) rule ants))])
             (lambda (x)
               `(letrec ([member?
                         (lambda (x ls)
                           (if (null? ls) #f
                               (if (equal? (car ls) x) #t
                                   (member? x (cdr ls)))))])
                  ,x)))))


(test
 (run 10 (q) (proof?o q #t))
 '((_.0 (_.0 . _.1) assumption ()) ((_.0 (_.1 _.0 . _.2) assumption ()) (=/= ((_.0 _.1))))
  ((_.0 (_.1 _.2 _.0 . _.3) assumption ())
    (=/= ((_.0 _.1)) ((_.0 _.2))))
  ((_.0 (_.1 _.2 _.3 _.0 . _.4) assumption ())
    (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.0 _.3))))
  ((_.0 => _.0)
    _.1
    conditional
    ((_.0 (_.0 . _.1) assumption ())))
  ((_.0 (_.1 _.2 _.3 _.4 _.0 . _.5) assumption ())
    (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.0 _.3)) ((_.0 _.4))))
  ((_.0 (_.1 _.2 _.3 _.4 _.5 _.0 . _.6) assumption ())
    (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.0 _.3)) ((_.0 _.4))
         ((_.0 _.5))))
  ((_.0 (_.1 _.2 _.3 _.4 _.5 _.6 _.0 . _.7) assumption ())
    (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.0 _.3)) ((_.0 _.4))
         ((_.0 _.5)) ((_.0 _.6))))
  ((_.0 (_.1 _.2 _.3 _.4 _.5 _.6 _.7 _.0 . _.8) assumption ())
    (=/= ((_.0 _.1)) ((_.0 _.2)) ((_.0 _.3)) ((_.0 _.4))
         ((_.0 _.5)) ((_.0 _.6)) ((_.0 _.7))))
  (((_.0 => _.1)
     (_.1 . _.2)
     conditional
     ((_.1 (_.0 _.1 . _.2) assumption ())))
   (=/= ((_.0 _.1))))))

(test
 (run* (q) (proof?o '(A (A (A => B) (B => C)) assumption ()) #t))
 '(_.0))
(test
 (run* (q) (proof?o '((A => B) (A (A => B) (B => C)) assumption ()) q))
 '(#t))
(test
 (run* (q) (proof?o '(B (A (A => B) (B => C))
                        modus-ponens
                        (((A => B) (A (A => B) (B => C)) assumption ())
                         (A (A (A => B) (B => C)) assumption ()))) q))
 '(#t))
(test
 (run 1 (prf)
      (fresh (body)
             ;; prove C holds, given A, A => B, B => C
             (== prf `(C (A (A => B) (B => C)) . ,body))
             (proof?o prf #t)))
 '((C (A (A => B) (B => C))
    modus-ponens
    (((B => C) (A (A => B) (B => C)) assumption ())
      (B (A (A => B) (B => C))
         modus-ponens
         (((A => B) (A (A => B) (B => C)) assumption ())
           (A (A (A => B) (B => C)) assumption ())))))))
(time-test
 (run 1 (prf)
   (fresh (body)
     ;; prove (A => B) => (B => C) => (A => C) holds absolutely
     (== prf `(((A => B) => ((B => C) => (A => C))) () . ,body))
     (proof?o prf #t)))
 '((((A => B) => ((B => C) => (A => C)))
   ()
   conditional
   ((((B => C) => (A => C))
      ((A => B))
      conditional
      (((A => C)
         ((B => C) (A => B))
         conditional
         ((C (A (B => C) (A => B))
             modus-ponens
             (((B => C) (A (B => C) (A => B)) assumption ())
               (B (A (B => C) (A => B))
                  modus-ponens
                  (((A => B) (A (B => C) (A => B)) assumption ())
                    (A (A (B => C) (A => B)) assumption ())))))))))))))

(time-test
 (run 1 (prf)
   (fresh (body)
     ;; prove commutativity of ∧, encoded with =>
     ;; ((A ∧ B) => (B ∧ A))
     ;; (¬(¬A ∨ ¬B) => ¬(¬B ∨ ¬A))
     ;; (¬(A => ¬B) => ¬(B => ¬A))
     ;; (((A => (B => C)) => C) => ((B => (A => C)) => C))
     (== prf `((((A => (B => C)) => C) => ((B => (A => C)) => C)) () . ,body))
     (proof?o prf #t)))
 '(((((A => (B => C)) => C) => ((B => (A => C)) => C))
    ()
    conditional
    ((((B => (A => C)) => C)
      (((A => (B => C)) => C))
      conditional
      ((C ((B => (A => C)) ((A => (B => C)) => C))
          modus-ponens
          ((((A => (B => C)) => C)
            ((B => (A => C)) ((A => (B => C)) => C))
            assumption
            ())
           ((A => (B => C))
            ((B => (A => C)) ((A => (B => C)) => C))
              conditional
              (((B => C)
                (A (B => (A => C)) ((A => (B => C)) => C))
                conditional
                ((C (B A (B => (A => C)) ((A => (B => C)) => C))
                     modus-ponens
                     (((A => C)
                       (B A (B => (A => C)) ((A => (B => C)) => C))
                       modus-ponens
                       (((B => (A => C))
                         (B A (B => (A => C)) ((A => (B => C)) => C))
                           assumption
                           ())
                        (B (B A (B => (A => C)) ((A => (B => C)) => C))
                           assumption
                           ())))
                      (A (B A (B => (A => C)) ((A => (B => C)) => C))
                          assumption
                          ())))))))))))))))


;; running with holes
(load "unstaged-interp.scm")
(define (gen-hole query result)
  (let ((r (run 1 (q)
             (eval-expo #t
                        (query q)
                        initial-env
                        (quasi result)))))
    (let ((r (car r)))
      (fix-scope
       `(lambda (,(car r)) (fresh () . ,(caddr r)))))))
(define (syn-hole query result)
  (let ((e (eval (gen-hole query result))))
    (run 1 (q) (e q))))

(test
 (syn-hole
  (lambda (q)
    `(letrec ((append
               (lambda (xs ys)
                 (if (null? xs) ,q
                     (cons (car xs) (append (cdr xs) ys))))))
       (append '(1 2) '(3 4))))
  '(1 2 3 4))
 '(ys))

;; mutually-recursive
(test
 (run 1 (q)
      (eval-expo #t
                 `(letrec ((even? (lambda (n)
                                    (if (equal? n 'z) #t
                                        (if (equal? n '(s z)) #f
                                            (odd? (car (cdr n)))))))
                           (odd? (lambda (n)
                                   (if (equal? n 'z) #f
                                       (if (equal? n '(s z)) #t
                                           (even? (car (cdr n))))))))
                    (even? '(s (s (s z)))))
                 initial-env
                 q))
 '((_.0 !!
      ((letrec ([even? (lambda (n)
                         (lambda (_.1)
                           (fresh ()
                             (== (cons _.2 (cons _.3 '()))
                                 (cons _.4 (cons _.5 '())))
                             (conde
                               ((== _.2 _.3) (== #t _.6))
                               ((=/= _.2 _.3) (== #f _.6)))
                             (== n _.4) (== _.5 'z)
                             (conde
                               ((=/= #f _.6) (== '#t _.1))
                               ((== #f _.6)
                                 (== (cons _.7 (cons _.8 '()))
                                     (cons _.9 (cons _.10 '())))
                                 (conde
                                   ((== _.7 _.8) (== #t _.11))
                                   ((=/= _.7 _.8) (== #f _.11)))
                                 (== n _.9)
                                 (== _.10 (cons 's (cons 'z '())))
                                 (conde
                                   ((=/= #f _.11) (== '#f _.1))
                                   ((== #f _.11)
                                     (== (cons (cons _.12 _.13) '())
                                         (cons _.14 '()))
                                     (== (cons (cons _.15 _.14) '())
                                         (cons _.16 '()))
                                     (== n _.16)
                                     ((odd? _.12) _.1))))))))]
                [odd? (lambda (n)
                        (lambda (_.17)
                          (fresh ()
                            (== (cons _.18 (cons _.19 '()))
                                (cons _.20 (cons _.21 '())))
                            (conde
                              ((== _.18 _.19) (== #t _.22))
                              ((=/= _.18 _.19) (== #f _.22)))
                            (== n _.20) (== _.21 'z)
                            (conde
                              ((=/= #f _.22) (== '#f _.17))
                              ((== #f _.22)
                                (== (cons _.23 (cons _.24 '()))
                                    (cons _.25 (cons _.26 '())))
                                (conde
                                  ((== _.23 _.24) (== #t _.27))
                                  ((=/= _.23 _.24) (== #f _.27)))
                                (== n _.25)
                                (== _.26 (cons 's (cons 'z '())))
                                (conde
                                  ((=/= #f _.27) (== '#t _.17))
                                  ((== #f _.27)
                                    (== (cons (cons _.28 _.29) '())
                                        (cons _.30 '()))
                                    (== (cons (cons _.31 _.30) '())
                                        (cons _.32 '()))
                                    (== n _.32)
                                    ((even? _.28) _.17))))))))])
         (fresh
           ()
           (== _.33
               (cons
                 's
                 (cons (cons 's (cons (cons 's (cons 'z '())) '())) '())))
           ((even? _.33) _.0)))))))

;; this requires
;; https://github.com/namin/faster-miniKanren/tree/staged
(define (micro query)
     `(letrec
       ((assp
         (lambda (p l)
           (if (null? l) #f
               (if (p (car (car l))) (car l)
                   (assp p (cdr l))))))

        (var
         (lambda (c) (cons 'var c)))
        (var?
         (lambda (x) (and (pair? x) (equal? (car x) 'var))))
        (var=?
         (lambda (x1 x2) (equal? (cdr x1) (cdr x2))))

        (walk
         (lambda (u s)
           ((lambda (pr) (if pr (walk (cdr pr) s) u))
            (and (var? u) (assp (lambda (v) (var=? u v)) s)))))

        (ext-s
         (lambda (x v s)
           (cons (cons x v) s)))

        (===
         (lambda (u v)
           (lambda (s/c)
             ((lambda (s) (if s (unit (cons s (cdr s/c))) (mzero)))
              (unify u v (car s/c))))))

        (unit
         (lambda (s/c)
           (cons s/c (mzero))))
        (mzero
         (lambda ()
           '()))

        (unify
         (lambda (u v s)
           ((lambda (u v)
              (if (and (var? u) (var? v) (var=? u v)) s
                  (if (var? u) (ext-s u v s)
                      (if (var? v) (ext-s v u s)
                          (if (and (pair? u) (pair? v))
                              ((lambda (s) (and s (unify (cdr u) (cdr v) s)))
                               (unify (car u) (car v) s))
                              (and (equal? u v) s))))))
            (walk u s) (walk v s))))

        (call/fresh
         (lambda (f)
           (lambda (s/c)
             ((lambda (c) ((f (var c)) (cons (car s/c) (cons 's c))))
              (cdr s/c)))))

        (disj
         (lambda (g1 g2)
           (lambda (s/c) (mplus (g1 s/c) (g2 s/c)))))
        (conj
         (lambda (g1 g2)
           (lambda (s/c) (bind (g1 s/c) g2))))

        (mplus
         (lambda ($1 $2)
           (if (null? $1) $2
               (if (pair? $1) (cons (car $1) (mplus (cdr $1) $2))
                   (lambda () (mplus $2 ($1)))))))

        (bind
         (lambda ($ g)
           (if (null? $) (mzero)
               (if (pair? $) (mplus (g (car $)) (bind (cdr $) g))
                   (lambda () (bind ($) g))))))

        (empty-state
         (lambda ()
           '(() . z)))

        (pull
         (lambda ($)
           (if (or (null? $) (pair? $)) $ (pull ($)))))

        (take-all
         (lambda ($)
           ((lambda ($) (if (null? $) '() (cons (car $) (take-all (cdr $)))))
            (pull $))))

        (take
         (lambda (n $)
           (if (equal? n 'z) '()
               ((lambda ($) (if (null? $) '() (cons (car $) (take (cdr n) (cdr $)))))
                (pull $)))))
)

     ,query

     ))

(define (gen-micro x)
  (let ((r
         (run 1 (q)
           (eval-expo
            #t
            (micro x)
            initial-env
            q))))
    (let ((r (car r)))
      (fix-scope
       `(lambda (out)
          (fresh ()
            (== ,(car r) out)
            . ,(caddr r)))))))

(define g1 (gen-micro 1))
(define t1 (eval g1))
(time-test (run 2 (q) (t1 q)) '(1))


(define my-mapo
  (eval
   (gen 'my-map '(f xs)
        '(if (null? xs) '()
             (cons (f (car xs))
                   (my-map f (cdr xs)))))))

(define h1o
  (eval
   (gen 'h1 '(f)
        '(f 1))))

(test
 (run 1
      (q)
      (h1o q 2))
 '(((closure (lambda _.0 2) _.1) (sym _.0))))

(test
 (run 1
      (q)
      (my-mapo
       q
       '((1) (2) (3))
       '(1 2 3)))
 '((prim . car)))

;; currying is painful
(define curried-appendo
  (eval
   (gen 'curried-append '(xs)
        '(lambda (ys)
           (if (null? xs) ys
               (cons (car xs)
                     ((curried-append (cdr xs)) ys)))))))

(define opt-curried-appendo
  (eval
   (gen 'opt-curried-append '(xs)
        '(if (null? xs) (lambda (ys) ys)
             (lambda (ys)
               (cons (car xs)
                     ((opt-curried-append (cdr xs)) ys)))))))

(test
 (run* (q)
       (fresh (p)
              (curried-appendo '(a) p)
              (fresh (l e)
                     (== p `(closure ,l ,e))
                     (u-eval-expo (list l (list 'quote '(b))) e q))))
 '((a b)))

(test
 (run* (q)
       (fresh (p)
              (opt-curried-appendo '(a) p)
              (fresh (l e)
                     (== p `(closure ,l ,e))
                     (u-eval-expo (list l (list 'quote '(b))) e q))))
 '((a b)))

(test
 (run* (q)
       (fresh (p)
              (curried-appendo q p)
              (fresh (l e)
                     (== p `(closure ,l ,e))
                     (u-eval-expo (list l (list 'quote '(b))) e '(a b)))))
 '((a)))

(test
 (run* (q)
       (fresh (p)
              (opt-curried-appendo q p)
              (fresh (l e)
                     (== p `(closure ,l ,e))
                     (u-eval-expo (list l (list 'quote '(b))) e '(a b)))))
 '((a)))

(test
 (run* (q) (fresh (x y p)
                  (== q (list x y))
                  (curried-appendo x p)
                  (fresh (l e)
                         (== p `(closure ,l ,e))
                         (u-eval-expo (list l (list 'quote y)) e '(a b c d e)))))
 '((() (a b c d e)) ((a) (b c d e)) ((a b) (c d e))
   ((a b c) (d e)) ((a b c d) (e)) ((a b c d e) ())))

(test
 (run* (q) (fresh (x y p)
                  (== q (list x y))
                  (opt-curried-appendo x p)
                  (fresh (l e)
                         (== p `(closure ,l ,e))
                         (u-eval-expo (list l (list 'quote y)) e '(a b c d e)))))
 '((() (a b c d e)) ((a) (b c d e)) ((a b) (c d e))
   ((a b c) (d e)) ((a b c d) (e)) ((a b c d e) ())))
