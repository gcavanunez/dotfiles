((text) @injection.content
    (#not-has-ancestor? @injection.content "envoy")
    (#set! injection.combined)
    (#set! injection.language php))

; could be bash or zsh
; or whatever tree-sitter grammar you have.
; ((text) @injection.content
;     (#has-ancestor? @injection.content "envoy")
;     (#set! injection.combined)
;     (#set! injection.language bash))

; ((php) @injection.content
;     (#set! injection.language "php")
;     (#set! injection.combined))
; ((parameter) @injection.content
;     (#set! injection.language "php")) ; TODO: php_only
; ((php_only) @injection.content
;     (#set! injection.language "php")) ; TODO: php_only
