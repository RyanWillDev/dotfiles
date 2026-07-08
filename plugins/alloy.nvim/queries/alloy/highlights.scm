; Comments
(line_comment)  @comment
(block_comment) @comment

; Literals
(integer_literal) @number
(constant)        @constant.builtin

; Keywords — paragraphs
[
  "module"
  "open"
  "as"
  "private"
  "sig"
  "extends"
  "in"
  "fact"
  "pred"
  "fun"
  "assert"
  "enum"
  "run"
  "check"
  "for"
  "but"
  "exactly"
  "expect"
] @keyword

; Keywords — modifiers / multiplicities / quantifiers
(abstract_keyword) @keyword.modifier
(var_keyword)      @keyword.modifier
"disj"             @keyword.modifier

(multiplicity) @keyword.modifier
(quantifier)   @keyword.repeat

; Operators — temporal (Alloy 6)
[
  "always"
  "eventually"
  "after"
  "before"
  "historically"
  "once"
  "until"
  "releases"
  "since"
  "triggered"
] @keyword.operator

; Operators — logical
[
  "and"
  "or"
  "not"
  "iff"
  "implies"
  "else"
  "let"
] @keyword.operator

; Punctuation / operators (symbols)
[
  "&&" "||" "!" "<=>" "=>"
  "=" "!=" "<" ">" "=<" "<=" ">="
  "+" "-" "&" "->" "<:" ":>" "."
  "~" "^" "*" "#"
  "!in"
] @operator

(not_in_op) @operator

; Punctuation
[ "{" "}" "[" "]" "(" ")" ] @punctuation.bracket
[ "," "|" ":" "/" ] @punctuation.delimiter

; Top-level declaration names
(sig_decl       names: (name_list (identifier) @type))
(sig_extends    parent: (qualified_name (identifier) @type .))
(enum_decl      name:  (identifier) @type)

(fact_decl      name:  (identifier) @function)
(pred_decl      name:  (identifier) @function)
(fun_decl       name:  (identifier) @function)
(assert_decl    name:  (identifier) @function)
(command_decl   target: (qualified_name (identifier) @function.call))
(command_decl   name:  (identifier) @label)
(command_decl   name:  (string_literal) @label)
(fact_decl      name:  (string_literal) @function)
(assert_decl    name:  (string_literal) @function)

(string_literal) @string

(call_expr      function: (qualified_name (identifier) @function.call .))

; Parameter / let-binding names
(decl           (identifier) @variable.parameter)
(let_binding    name: (identifier) @variable)

; Module / open names
(module_decl    name: (qualified_name (identifier) @namespace))
(open_decl      name: (qualified_name (identifier) @namespace))

; Field names
(field_decl     (name_list (identifier) @property))

; Default: identifier in qualified_name → variable
(qualified_name (identifier) @variable)
