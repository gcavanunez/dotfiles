; [
;   (directive)
;   (directive_start)
;   (directive_end)
; ] @keyword

; ([
;   (bracket_start)
;   (bracket_end)
; ] @punctuation.special (#set! "priority" 110))

; (comment) @comment @spell

; (directive) @function
; (directive_start) @function
; (directive_end) @function
; (comment) @comment
; ((parameter) @include (#set! "priority" 110))
; ((php_only) @include (#set! "priority" 110))
; ((bracket_start) @function (#set! "priority" 120))
; ((bracket_end) @function (#set! "priority" 120))
; (keyword) @function


; (directive) @tag
; (directive_start) @tag
; (directive_end) @tag
; ((comment) @comment @spell (#set! priority 101))

; (directive) @tag
; (directive_start) @tag
; (directive_end) @tag
; (comment) @comment

; (directive) @tag
; (directive_start) @tag
; (directive_end) @tag
; ((comment) @comment @spell (#set! priority 101))
; ((parameter) @include (#set! "priority" 110))
; ((php_only) @include (#set! "priority" 110))
; ((bracket_start) @function (#set! "priority" 120))
; ((bracket_end) @function (#set! "priority" 120))
; (keyword) @function

(directive) @function
(directive_start) @function @nospell
(directive_end) @function @nospell
(comment) @comment
((parameter) @include (#set! "priority" 110))
((php_only) @include (#set! "priority" 110))
((bracket_start) @function (#set! "priority" 120))
((bracket_end) @function (#set! "priority" 120))
(keyword) @function
