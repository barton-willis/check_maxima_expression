(in-package :maxima)

;; We could check the car of an expression for things like multiple simp flags
;; and for extraneous rubbish. And we could check the arguments of bigfloats 
;; to make sure the arguments aren't rubbish.
(defun symbol-or-string-p (x)
  (or (symbolp x)
      (stringp x)))

;; This should allow only one simp flag, only one member of the form (integer string src), and likely
;; a few more things.
(defun ok-expression-car (e)
  (flet ((ok (x)  (or (symbolp x) (and (consp x) (every #'symbol-or-string-p x)))))
  (and(consp e) (ok e))))

;; We could check the car of an expression for things like multiple simp flags
;; and for extraneous rubbish. And we could check the arguments of bigfloats 
;; to make sure the arguments aren't rubbish.
(defun proper-expression-p (e &optional (flag))
  (cond
    ((symbolp e) (values t e 'symbol))

    ;; We should check mrat args
    ((and (consp e)
          (consp (car e))
          (eq 'mrat (caar e))) (values t e 'mrat))

    ((and (consp e) (every #'(lambda (q) (proper-expression-p q nil)) e)) (values nil e 'cl-list-expressions))
    
    ((and (consp e) (not (ok-expression-car (car e)))) (values nil e 'naked-cl-list))

    ((or (eq e t)
         (eq e nil)) (values t e 'boolean))

    ((stringp e) (values t e 'string))

    (($ratnump e) (values t e 'number))  ; not mnump, numberp, or ratnump!

    ((floatp e) (values t e (type-of e)))

    ((complexp e) (values nil e 'cl-complex))

    ((rationalp e) (values nil e 'cl-rational))

    ((arrayp e) (values t e 'array))

    ((eq (type-of e) 'hash-table) (values t e 'hash-table))

    ((and flag
          (consp e)
          (consp (car e))
          (ok-expression-car (car e))
          (not (member 'simp (car e))))
     (values nil e 'missing-simp-flag))

    ((eq (type-of e) 'function) (values t e 'function))

    ;; catches bigfloats too!
    ((and (consp e)
          (consp (car e))
          (ok-expression-car (car e))) 
     ;; When e has a simp flag, all of its arguments should have a simp flag.
     (setq flag
           (cond ((eq 'mdefine (caar e)) nil) ; mdefine expressions get a simp flag pass
                 (t (member 'simp (car e))))) ; should this be (or flag (member ...)) ?

     (catch 'oops
       (dolist (q (cdr e))
         (multiple-value-bind (bool x reason)
             (proper-expression-p q flag)
           (when (not bool)
             (throw 'oops (values bool x reason)))))
       (throw 'oops (values t e 'general-expression))))

    (t
     (values nil e 'unknown))))


(defmfun $check_expression (x)
  (multiple-value-bind (bool e reason) 
		(proper-expression-p x t)
		(cond ((not bool)
		         (let ((*standard-output* *debug-io*)) 
		            (mtell "Bad expression: expr = ~M ; reason = ~M ~%" e reason)))
          (t '$done)))) 

