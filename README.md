# check_maxima_expression

 The function `check_expression` checks a Maxima expression for missing `simp` flags and a few other defects. This function is mostly useful for developers, not users.
 
 To use this function, put the file `check-expression-p.lisp` in a folder that Maxima can find. Here are some examples

 ```
(%i1) load("check-expression-p.lisp")$

(%i2) check_expression(a+b);
(%o2) done
```
Here is an example of an expression with a missing `simp` flag: 

```
(%i3) :lisp(msetq \$xxx '((%sin simp) ((%sin) 7)))

(%i3) check_expression(xxx);
Bad expression: expr = sin(7) ; reason = missing-simp-flag
(%o3)  false
```
And a test that shows that `check_expression` detects a rational number as a bogus expression:
```
(%i4) :lisp(msetq \$xxx (/ 5 7))

(%i4) check_expression(xxx);
                       5
Bad expression: expr = ─ ; reason = cl-rational
                       7

```
