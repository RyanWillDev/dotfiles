if exists("b:current_syntax")
  finish
endif

syntax match alloyOutHeader  /^▸.*$/
syntax match alloyOutSummaryOk    /^✔.*$/
syntax match alloyOutSummaryFail  /^✘.*$/
syntax match alloyOutSummaryNeutral /^▾.*$/
syntax keyword alloyOutSat   SAT
syntax keyword alloyOutUnsat UNSAT
syntax match alloyOutInstance /\<\(Instance found\|No instance found\)\>/
syntax match alloyOutWarn    /^\(WARNING\|fatal\|Error\)\>.*$/

highlight default link alloyOutHeader         Title
highlight default link alloyOutSummaryOk      DiagnosticOk
highlight default link alloyOutSummaryFail    DiagnosticError
highlight default link alloyOutSummaryNeutral Comment
highlight default link alloyOutSat            DiagnosticOk
highlight default link alloyOutUnsat          DiagnosticWarn
highlight default link alloyOutInstance       Special
highlight default link alloyOutWarn           DiagnosticError

let b:current_syntax = "alloy-output"
