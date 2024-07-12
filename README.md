# check_maxima_expression
 Check a Maxima expression for missing simp flags and other defects. Assuming the file `check-expression-p.lisp` is in a folder that Maxima can find, here are some examples

 ```
(%i1) load("check-expression-p.lisp")$

(%i2) check_expression(a+b,true);
(%o2) done

```
Construct several Maxima expression with a missing `simp` flag and check it
```
(%i3) :lisp(msetq \$xxx '((%sin simp) ((%sin) 7))))$

(%i3) check_expression(xxx,true);
Bad expression: expr = sin(7) ; reason = missing-simp-flag
(%o3)  false

(%i4) :lisp(msetq \$xxx (/ 5 7))

(%i4) check_expression(xxx,true);
                       5
Bad expression: expr = ─ ; reason = cl-rational
                       7

```
