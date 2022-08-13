;;; tsort, api from SLIB -*- scheme -*-
(define-library (srfi 234)
  (export topological-sort)
  (import
   (scheme base)
   (srfi 1)
   (srfi 117))
  (cond-expand
    ((library (srfi 125))
     (import (rename (srfi 125)
               (make-hash-table make-hashtable)
               (hash-table-ref hashtable-lookup)
    ((library (srfi 126))
     (import (srfi 126))))
  (include "topological-sort-impl.scm"))
(define-library (tsort)
  (export tsort)
  (import topological-sort))
