;; We could check the car of an expression for things like multiple simp flags
;; and for extraneous rubbish. And we could check the arguments of bigfloats 
;; to make sure the arguments aren't rubbish.
(defun proper-expression-p (e &optional (flag))
	(cond ((symbolp e) (values t e 'symbol))
        ((or (eq e t) (eq t nil)) (values t e 'boolean))
        ((stringp e) (values t e 'string))
		(($ratnump e) (values t e 'number)) ; not mnump, numberp, or ratnump!
	    ((floatp e) (values t e (type-of e)))  
		((complexp e) (values nil e 'cl-complex))
		((rationalp e) (values nil e 'cl-rational))
        ((arrayp e) (values t e 'array))
        ((eq (type-of e) 'hash-table) (values t e 'hash-table))
        ;; We should check mrat args
        ((and (consp e) (consp (car e)) (eq 'mrat (caar e))) (values t e 'mrat))
        ((and flag (consp e) (consp (car e)) (not (member 'simp (car e))))
          (values nil e 'missing-simp-flag))
        ((eq (type-of e) 'function) (values t e 'function))
        ((and (consp e) (consp (car e))) ;catches bigfloats too!
           ;;When e has a simp flag, all of its arguments should have a simp flag.
		      (setq flag 
            	  (cond ((eq 'mdefine (caar e)) nil) ; mdefine expressions get a simp flag pass
                	    (t (member 'simp (car e))))) ; should this be (or flag (member ...))
            (catch 'oops
             (dolist (q (cdr e))
                  (multiple-value-bind (bool x reason) 
                    (proper-expression-p q flag)
                    (when (not bool)
                      (throw 'oops (values bool x reason)))))
             (throw 'oops (values t e (caar e)))))         
        (t (values nil e (type-of e)))))

(defmfun $check_expression (x flag)
  (multiple-value-bind (bool e reason) 
		(proper-expression-p x flag)
		(cond ((not bool)
		         (let ((*standard-output* *debug-io*)) 
		            (mtell "simplifya: expr = ~M ; reason = ~M ~%" e reason)))
          (t '$done)))) 

