
(library (extra-gc)
  (export
    add-collector!
    custom-collect
    make-custom-collector)
  (import (chezscheme))

(define custom-collectors '())

(define custom-collection-count 100)

(meta-cond
  [(threaded?)
   (define m (make-mutex))
   (define-syntax critical
     (syntax-rules ()
       [(_ b b* ...)
        (with-mutex m
          b b* ...)]))]
  [else
   (alias critical begin)])

(define (add-collector! c)
  (assert (procedure? c))
  (critical
    (set! custom-collectors
      (cons c custom-collectors))))

(define make-custom-collector
  (case-lambda
    [(free guardian)
     (make-custom-collector free guardian custom-collection-count)]
    [(free guardian count)
     (assert
       (and (procedure? free)
            (procedure? guardian)
            (integer? count)
            (exact? count)
            (positive? count)))
     (lambda ()
       (do ([count count (- count 1)]
            [obj (guardian) (guardian)])
            [(or (not obj)
                 (zero? count))]
         (free obj)))]))

(define (custom-collect)
  (collect)
  (critical
    (for-each (lambda (c) (c))
      custom-collectors)))

(collect-request-handler custom-collect)
)
