[![Actions Status](https://github.com/FCO/ASTQuery/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/ASTQuery/actions)

NAME
====

ASTQuery - Query and manipulate Raku’s Abstract Syntax Trees (RakuAST) with an expressive syntax

INSTALLATION
============

- Install project dependencies (without running tests):
  - `zef install --/test --test-depends --deps-only .`
- Optional: install the test runner and coverage tools:
  - `zef install --/test App::Prove6`
  - `zef install --/test App::RaCoCo`

QUICKSTART
==========

```raku
use ASTQuery;

my $code = q:to/CODE/;
    sub f($x) { }
    f 42;
    say 1 * 3;
CODE

my $ast = $code.AST;

# Find Apply* operator nodes where left=1 and right=3
my $ops = $ast.&ast-query('.apply-operator[left=1, right=3]');
say $ops.list;

# Find calls that have an Int somewhere under args
my $calls = $ast.&ast-query('&is-call[args=>>> .int]');
say $calls.list;
```

SYNOPSIS
========

```raku
use ASTQuery;

# Sample Raku code
my $code = q{
    for ^10 {
        if $_ %% 2 {
            say $_ * 3;
        }
    }
};

# Generate the AST
my $ast = $code.AST;

# Example 1: Find 'apply-op' nodes where left operand is 1 and right operand is 3
my $result1 = $ast.&ast-query('.apply-operator[left=1, right=3]');
say $result1.list;  # Outputs matching nodes
```

Output
------

```raku
[
  RakuAST::ApplyInfix.new(
    left  => RakuAST::IntLiteral.new(1),
    infix => RakuAST::Infix.new("*"),
    right => RakuAST::IntLiteral.new(3)
  )
]
```

DESCRIPTION
===========

ASTQuery provides a compact, composable query language for traversing and matching nodes in
Raku’s RakuAST. It lets you precisely match nodes, relationships (child/descendant/ancestor), and
attributes, capture interesting nodes, and even register custom function matchers for reuse.

Key Features
------------

- Expressive Query Syntax: Define complex queries concisely.
- Relationship Operators: Parent/child, ancestor/descendant, and ignorable-skipping variants.
- Named Captures: Capture matched nodes for later retrieval.
- Attribute Matching: Compare values, traverse attributes, and run regexes.
- Custom Functions: Register reusable matchers via `&name` (built-ins included).
- CLI Utility: Query files on disk and print results in a readable form.

CLI
===

- Run against a directory or a single file:
  - `raku -I. bin/ast-query.raku '<selector>' [path]`
  - If `path` is omitted, scans the current directory recursively.
  - Scans files with extensions: `raku`, `rakumod`, `rakutest`, `rakuconfig`, `p6`, `pl6`, `pm6`.
- Example:
  - `raku -I. bin/ast-query.raku '.call#say >>> .int' lib/`
- Output shows matched nodes and any captures in a human-friendly, deparsed format.

QUERY LANGUAGE REFERENCE
========================

Node Description
----------------

Format:

`RakuAST::Class::Name.group#id[attr1, attr2=attrvalue]$name&function`

Components:

- `RakuAST::Class::Name`: Optional full class name to match exactly.
- `.group`: Optional group alias (predefined; see Groups below).
- `#id`: Optional id value compared against the node’s “id field”.
- `[attributes]`: Optional one or more attribute matchers (see operators below).
- `$name`: Optional capture name (only one per node part).
- `&function`: Optional registered function matcher. Multiple functions compose with AND.

Relationship Operators
----------------------

- `>`: Left has the right as a child.
- `>>`: Left has the right as a descendant, skipping only “ignorable” nodes between them.
- `>>>`: Left has the right as a descendant, allowing any nodes in between.
- `<`: Right is the parent of the left.
- `<<`: Right is an ancestor of the left, skipping only ignorable nodes.
- `<<<`: Right is an ancestor of the left, allowing any nodes in between.

Ignorable Nodes
---------------

Skipped by `>>` and `<<`:

- `RakuAST::Block`, `RakuAST::Blockoid`, `RakuAST::StatementList`,
  `RakuAST::Statement::Expression`, `RakuAST::ArgList`.

Attributes: Values and Traversals
---------------------------------

- `[attr=value]`:
  - If the attribute is a RakuAST node, the matcher follows the node’s configured id field to a
    leaf value for comparison. Non-existent attributes never match.
  - Literal numbers and strings, nested matchers, or types are supported.
- Value operators on the leaf value:
  - `[attr~= value]`: contains (substring) or regex; if `value` is a regex literal `/.../`.
  - `[attr^= value]`: starts-with.
  - `[attr$= value]`: ends-with.
  - `[attr*=/regex/]`: regex match using `/.../` literal (flags not yet supported).
- Traversal from attribute value (if it is itself a RakuAST node):
  - `[attr=> MATCH]`: child relation from the attribute node.
  - `[attr=>> MATCH]`: descendant via ignorable nodes.
  - `[attr=>>> MATCH]`: descendant (any nodes).

Function Matchers (`&name`)
---------------------------

Register reusable matchers and reference them via `&name` inside node parts. Functions compose
with other constraints using AND semantics.

```raku
use ASTQuery;

# From a selector string
new-function '&has-int' => 'RakuAST::Node >>> .int';

# From a compiled matcher
new-function '&f-call', ast-matcher('.call#f');

# From a Callable (returns Bool for a node)
new-function '&single-argument-call' => -> $n {
	$n.^name.starts-with('RakuAST::Call')
	&& $n.args.defined && $n.args.args.defined
	&& $n.args.args.elems == 1
};

# Using functions
$ast.&ast-query('&has-int');
$ast.&ast-query('&is-call&has-int');
$ast.&ast-query('&is-call[args=>>> .int]');
```

Built-in functions (registered at module load):

- `&is-call`, `&is-operator`, `&is-apply-operator`
- `&is-assignment`, `&is-conditional`
- `&has-var`, `&has-call`, `&has-int`

Groups (Common Aliases)
-----------------------

These make queries shorter by avoiding full class names:

- `.call` → `RakuAST::Call`
- `.apply-operator` → `RakuAST::ApplyInfix|ApplyListInfix|ApplyPostfix|Ternary`
- `.operator` → `RakuAST::Infixish|Prefixish|Postfixish`
- `.conditional` → `IfWith|Unless|Without`
- `.variable`, `.variable-usage`, `.variable-declaration`
- `.statement`, `.expression`, `.int`, `.str`, `.ignorable`

You can add your own via `add-ast-group` and `add-to-ast-group`.

Captures and Results
--------------------

- `$name` captures the matched node under that name; the result object is `ASTQuery::Match`.
- Access results:
  - `@result.list`: all nodes that matched the entire selector.
  - `%result.hash`: captures keyed by `$name` and id-based keys.
- The object does Positional and Associative, so `result[0]` and `result<name>` work.

More Examples
-------------

```raku
# Call named 'say' that has an Int descendant
$ast.&ast-query('.call#say >>> .int');

# Calls whose name contains "bar"
$ast.&ast-query('&is-call[name~= bar]');

# Apply operator that uses Int operands somewhere under left or right
$ast.&ast-query('.apply-operator[left=>>> .int]');

# Composition with captures
$ast.&ast-query('RakuAST::Infix <<< .conditional$cond .int#2$two');
```

PROGRAMMATIC API
================

- `ast-query($ast, Str $selector)` and `ast-query($ast, $matcher)`:
  - Run a query over a RakuAST. Returns `ASTQuery::Match`.
- `ast-matcher(Str $selector)`:
  - Compile a selector into a matcher object for reuse.
- `new-function($name, $callable|$matcher|$selector)`:
  - Register a function matcher usable as `&name`.
- `add-ast-group($name, @classes)` / `add-to-ast-group($name, *@classes)`:
  - Create or extend group aliases.
- `set-ast-id($class, $id-method)`:
  - Configure which attribute is considered the node’s id field.

LIMITATIONS AND NOTES
=====================

- Regex flags are not yet supported in `/.../` literals.
- Only one `$name` capture per node part is supported.
- The space operator is not used; explicit operators control relationships.

DEBUGGING
=========

- Set `ASTQUERY_DEBUG=1` to print a tree of matcher decisions with deparsed node snippets.
- Example: `ASTQUERY_DEBUG=1 raku -I. -e 'use ASTQuery; say $*PROGRAM.succ'` (adjust to your use).
- The repository includes a `trace.png` screenshot of a debug trace.

TESTING AND COVERAGE
====================

- Run tests: `prove6 -I. t`
- Check coverage (after installing App::RaCoCo): `raku -I. tools/coverage.raku`
- Pre-commit coverage check: `raku -I. tools/coverage-check.raku`

CONTRIBUTING
============

- Feedback and PRs welcome!
- Follow Conventional Commits for messages (feat, fix, docs, test, chore, …).

LICENSE
=======

Artistic License 2.0. Copyright 2024 Fernando Corrêa de Oliveira.
