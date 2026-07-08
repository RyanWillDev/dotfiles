// Tree-sitter grammar for Alloy 6
// Inspired by https://github.com/bakaq/tree-sitter-alloy6 (sig-only stub),
// extended to cover modules, opens, facts, predicates, functions, assertions,
// commands, the full expression language, and Alloy 6 temporal operators.

// Prefix forms (quant, let) must have LOWER precedence than any binary op so
// that their body extends rightward across operators rather than reducing early.
const PREC = {
  quant:     -2,
  let:       -2,
  iff:        1,
  implies:    2,
  or:         3,
  and:        4,
  binTemp:    5,
  unaryLogic: 6,
  compare:    7,
  cardinality: 8,
  add:       10,
  intersect: 11,
  arrow:     12,
  restrict:  13,
  boxJoin:   14,
  dot:       15,
  unaryRel:  16,
};

module.exports = grammar({
  name: 'alloy',

  word: $ => $.identifier,

  extras: $ => [
    /\s/,
    $.line_comment,
    $.block_comment,
  ],

  conflicts: $ => [
    [$.decl, $.expression],
    [$.scope_decl, $.typescope],
    [$.decl],
    [$.multiplicity, $.quantifier],
    [$.qualified_name, $._decl_lhs],
  ],

  rules: {
    source_file: $ => seq(
      optional($.module_decl),
      repeat($.open_decl),
      repeat($._paragraph),
    ),

    // -------- comments --------
    line_comment: _ => token(choice(seq('//', /[^\n]*/), seq('--', /[^\n]*/))),
    block_comment: _ => token(seq('/*', /[^*]*\*+([^/*][^*]*\*+)*/, '/')),

    // -------- module / open --------
    module_decl: $ => seq(
      'module',
      field('name', $.qualified_name),
      optional(seq('[', commaSep1($.identifier), ']')),
    ),

    open_decl: $ => seq(
      optional('private'),
      'open',
      field('name', $.qualified_name),
      optional(seq('[', commaSep1($.qualified_name), ']')),
      optional(seq('as', $.identifier)),
    ),

    // -------- top-level paragraphs --------
    _paragraph: $ => choice(
      $.sig_decl,
      $.fact_decl,
      $.pred_decl,
      $.fun_decl,
      $.assert_decl,
      $.command_decl,
      $.enum_decl,
    ),

    // -------- sig --------
    sig_decl: $ => seq(
      optional($.var_keyword),
      optional($.abstract_keyword),
      optional($.multiplicity),
      'sig',
      field('names', $.name_list),
      optional(choice($.sig_extends, $.sig_in)),
      '{',
      optional($.field_list),
      '}',
      optional($.block),
    ),

    abstract_keyword: _ => 'abstract',
    var_keyword: _ => 'var',
    multiplicity: _ => choice('one', 'lone', 'some', 'set'),

    sig_extends: $ => seq('extends', field('parent', $.qualified_name)),
    sig_in: $ => seq('in', $.qualified_name, repeat(seq('+', $.qualified_name))),

    field_list: $ => seq(commaSep1($.field_decl), optional(',')),
    field_decl: $ => seq(
      optional($.var_keyword),
      optional('disj'),
      $.name_list,
      ':',
      optional('disj'),
      optional($.multiplicity),
      $._expr,
    ),

    name_list: $ => commaSep1($.identifier),

    // -------- enum (sugar in Alloy 6) --------
    enum_decl: $ => seq(
      'enum',
      field('name', $.identifier),
      '{',
      commaSep1($.identifier),
      '}',
    ),

    string_literal: _ => token(seq('"', /[^"\n]*/, '"')),

    _decl_name: $ => choice($.identifier, $.string_literal),

    // -------- fact / pred / fun / assert --------
    fact_decl: $ => seq(
      'fact',
      optional(field('name', $._decl_name)),
      $.block,
    ),

    pred_decl: $ => seq(
      'pred',
      optional(seq(field('receiver', $.qualified_name), '.')),
      field('name', $.identifier),
      optional($.param_list),
      $.block,
    ),

    fun_decl: $ => seq(
      'fun',
      optional(seq(field('receiver', $.qualified_name), '.')),
      field('name', $.identifier),
      optional($.param_list),
      ':',
      field('return_type', $._expr),
      '{',
      $._expr,
      '}',
    ),

    assert_decl: $ => seq(
      'assert',
      optional(field('name', $._decl_name)),
      $.block,
    ),

    param_list: $ => choice(
      seq('[', optional(commaSep1($.decl)), ']'),
      seq('(', optional(commaSep1($.decl)), ')'),
    ),

    decl: $ => seq(
      optional($.var_keyword),
      optional('disj'),
      $._decl_lhs,
      ':',
      optional('disj'),
      optional($.multiplicity),
      $._expr,
    ),

    _decl_lhs: $ => commaSep1($.identifier),

    // -------- commands --------
    // Alloy allows: `run`, `run name`, `run { ... }`, `run name { ... }`
    // (and the same for `check`). At least one of target/block is required.
    command_decl: $ => seq(
      optional(seq(field('name', $._decl_name), ':')),
      choice('run', 'check'),
      choice(
        seq(field('target', $.qualified_name), optional($.block)),
        $.block,
      ),
      optional($.scope_decl),
      optional(seq('expect', $.integer_literal)),
    ),

    scope_decl: $ => seq(
      'for',
      choice(
        seq($.integer_literal, optional(seq('but', commaSep1($.typescope)))),
        commaSep1($.typescope),
      ),
    ),

    typescope: $ => seq(
      optional('exactly'),
      $.integer_literal,
      $.qualified_name,
    ),

    // -------- blocks --------
    block: $ => seq('{', repeat($._expr), '}'),

    // -------- expressions --------
    _expr: $ => choice(
      $.quant_expr,
      $.let_expr,
      $.if_expr,
      $.binary_expr,
      $.unary_expr,
      $.box_join_expr,
      $.call_expr,
      $.comprehension,
      $.parenthesized_expr,
      $.block,
      $.qualified_name,
      $._literal,
    ),
    expression: $ => $._expr,

    _literal: $ => choice(
      $.integer_literal,
      $.constant,
    ),

    constant: _ => choice('none', 'univ', 'iden', 'Int', 'String'),
    integer_literal: _ => /-?[0-9]+/,

    parenthesized_expr: $ => seq('(', $._expr, ')'),

    comprehension: $ => seq('{', commaSep1($.decl), '|', $._expr, '}'),

    quant_expr: $ => prec.right(PREC.quant, seq(
      $.quantifier,
      optional('disj'),
      choice(
        // Quantifier form: `some x : T | P` or `some x : T { ... }`
        prec.dynamic(1, seq(
          commaSep1($.decl),
          choice(seq('|', $._expr), $.block),
        )),
        // Multiplicity test form: `some E`, `no E`, `lone E`, `one E`.
        // `all` and `sum` are excluded — they only have the quantifier form.
        $._expr,
      ),
    )),

    quantifier: _ => choice('all', 'no', 'some', 'lone', 'one', 'sum'),

    let_expr: $ => prec.right(PREC.let, seq(
      'let',
      commaSep1($.let_binding),
      choice(
        seq('|', $._expr),
        $.block,
      ),
    )),

    let_binding: $ => seq(field('name', $.identifier), '=', $._expr),

    if_expr: $ => prec.right(PREC.implies, seq(
      $._expr,
      '=>',
      $._expr,
      'else',
      $._expr,
    )),

    call_expr: $ => prec(PREC.boxJoin, seq(
      field('function', $.qualified_name),
      choice(
        seq('[', optional(commaSep1($._expr)), ']'),
        // bare-arg form sometimes used in Alloy: f x — left to parenthesized
      ),
    )),

    box_join_expr: $ => prec.left(PREC.boxJoin, seq(
      field('object', $._expr),
      '[',
      optional(commaSep1($._expr)),
      ']',
    )),

    unary_expr: $ => choice(
      prec(PREC.unaryRel,    seq(field('op', choice('~', '^', '*')), $._expr)),
      prec(PREC.cardinality, seq(field('op', '#'),                    $._expr)),
      prec(PREC.unaryLogic,  seq(field('op', choice(
        '!', 'not',
        'always', 'eventually', 'after', 'before', 'historically', 'once',
      )), $._expr)),
    ),

    not_in_op: _ => token(seq('not', /\s+/, 'in')),

    binary_expr: $ => {
      const table = [
        [PREC.dot,       '.',          'left'],
        [PREC.restrict,  '<:',         'left'],
        [PREC.restrict,  ':>',         'left'],
        [PREC.arrow,     '->',         'right'],
        [PREC.intersect, '&',          'left'],
        [PREC.add,       '+',          'left'],
        [PREC.add,       '-',          'left'],
        [PREC.compare,   '=',          'left'],
        [PREC.compare,   '!=',         'left'],
        [PREC.compare,   'in',         'left'],
        [PREC.compare,   '!in',        'left'],
        [PREC.compare,   '<',          'left'],
        [PREC.compare,   '>',          'left'],
        [PREC.compare,   '=<',         'left'],
        [PREC.compare,   '<=',         'left'],
        [PREC.compare,   '>=',         'left'],
        [PREC.binTemp,   'until',      'right'],
        [PREC.binTemp,   'releases',   'right'],
        [PREC.binTemp,   'since',      'right'],
        [PREC.binTemp,   'triggered',  'right'],
        [PREC.and,       '&&',         'left'],
        [PREC.and,       'and',        'left'],
        [PREC.or,        '||',         'left'],
        [PREC.or,        'or',         'left'],
        [PREC.implies,   '=>',         'right'],
        [PREC.implies,   'implies',    'right'],
        [PREC.iff,       '<=>',        'right'],
        [PREC.iff,       'iff',        'right'],
      ];
      return choice(
        ...table.map(([p, op, assoc]) => {
          const builder = assoc === 'left' ? prec.left : prec.right;
          return builder(p, seq(
            field('left', $._expr),
            field('op', op),
            field('right', $._expr),
          ));
        }),
        prec.left(PREC.compare, seq(
          field('left', $._expr),
          field('op', $.not_in_op),
          field('right', $._expr),
        )),
      );
    },

    // -------- names --------
    qualified_name: $ => seq(
      optional(seq('this', '/')),
      $.identifier,
      repeat(seq('/', $.identifier)),
    ),

    identifier: _ => /[A-Za-z_][A-Za-z0-9_'"]*/,
  },
});

function commaSep1(rule) {
  return seq(rule, repeat(seq(',', rule)));
}
