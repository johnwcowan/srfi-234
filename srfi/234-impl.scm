;;; topological sort using Kahn's algorithm.

(define-record-type node
  (make-node edges-out edges-in)
  node?
  (edges-out edges-out)
  (edges-in edges-in edges-in-set!))

;; Handle input with duplicate vertices, like tsort(1) input tends to have. Also clears out
;; edges that point back to the origin vertex.
;; ((a b) (a c) (d d)) -> ((a b c) (d))
(define (tsort-merge-vertices dag comparator)
  (let* ((g (make-hashtable comparator))
         (insert-or-merge (lambda (vertex)
                            (let*-values
                                (((name) (car vertex))
                                 ((b found) (hashtable-lookup g name)))
                              (if found
                                  (hashtable-set!
                                   g name (append (cdr vertex) b))
                                  (hashtable-set!
                                   g name (cdr vertex)))))))
    (for-each insert-or-merge dag)
    (hashtable-map->lset g (lambda (name edges)
                             (cons name (delete! name edges pred?))))))

(define (tsort-build-graph dag pred?)
  (let* ((g (make-hashtable comparator))
         (build-node
          (lambda (rawnode)
            (let ((node (make-node (cdr rawnode) '())))
              (hashtable-set! g (car rawnode) node))))
         (add-incoming
          (lambda (name node)
            (let ((add
                   (lambda (dname)
                     (let-values
                         (((dest found) (hashtable-lookup g dname)))
                       (if found
                           (edges-in-set! dest
                                          (cons name (edges-in dest)))
                           (hashtable-set!
                            g dname
                            (make-node '() (list name))))))))
              (for-each add (edges-out node))))))
    (for-each build-node (tsort-merge-vertices dag pred?))
    (hashtable-walk g add-incoming)
    g))
    
(define (tsort-fill-start-nodes g)
  (let ((s (make-queue)))
    (hashtable-walk g (lambda (name node)
                        (if (null? (edges-in node))
                            (enqueue! s name))))
    s))

(define (tsort-has-edges? g)
  (let-values (((k v match)
                (hashtable-find g (lambda (name node)
                                    (not (null? (edges-in node)))))))
    match))

(define (tsort dag pred?)
  (let* ((l (list-queue))
         (g (tsort-build-graph dag pred?))
         (s (tsort-fill-start-nodes g)))
    (let loop ()
      (if (not (queue-empty? s))
          (let* ((name (dequeue! s))
                 (node (hashtable-ref g name)))
            (list-queue-add-back! l name)
            (for-each (lambda (dest)
                        (let ((dnode (hashtable-ref g dest)))
                          (edges-in-set! dnode (delete name (edges-in dnode) pred?))
                          (if (null? (edges-in dnode))
                              (enqueue! s dest))))
                      (edges-out node))
            (loop))))
    (if (tsort-has-edges? g)
        #f
        (list-queue-list l))))

(define topological-sort tsort)
