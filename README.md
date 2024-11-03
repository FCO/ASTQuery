[![Actions Status](https://github.com/FCO/ASTQuery/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/ASTQuery/actions)

NAME
====

ASTQuery - Query and manipulate Raku’s Abstract Syntax Trees (RakuAST) with an expressive syntax

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
my $result1 = $ast.&ast-query('.apply-op[left=1, right=3]');
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

ASTQuery simplifies querying and manipulating Raku’s ASTs using a powerful query language. It allows precise selection of nodes and relationships, enabling effective code analysis and transformation.

Key Features
------------

  * Expressive Query Syntax: Define complex queries to match specific AST nodes.

  * Node Relationships: Use operators to specify parent-child and ancestor-descendant relationships.

  * Named Captures: Capture matched nodes for easy retrieval.

  * AST Manipulation: Modify the AST for code transformations and refactoring.

QUERY LANGUAGE SYNTAX
=====================

Node Description
----------------

Format:

`RakuAST::Class::Name.group#id[attr1, attr2=attrvalue]$name`

Components:

  * `RakuAST::Class::Name`: (Optional) Full class name.

  * `.group`: (Optional) Node group (predefined).

  * `#id`: (Optional) Identifier attribute.

  * `[attributes]`: (Optional) Attributes to match.

  * `$name`: (Optional) Capture name.

Note: Use only one $name per node.

Operators
---------

  * `>` : Left node has the right node as a child.

  * `<` : Right node is the parent of the left node.

  * `>>>`: Left node has the right node as a descendant (any nodes can be between them).

  * `>>`: Left node has the right node as a descendant, with only ignorable nodes in between.

  * `<<<`: Right node is an ancestor of the left node (any nodes can be between them).

  * `<<`: Right node is an ancestor of the left node, with only ignorable nodes in between.

Note: The space operator is no longer used.

Ignorable Nodes
---------------

Nodes skipped by `>>` and `<<` operators:

  * `RakuAST::Block`

  * `RakuAST::Blockoid`

  * `RakuAST::StatementList`

  * `RakuAST::Statement::Expression`

  * `RakuAST::ArgList`

EXAMPLES
========

Example 1: Matching Specific Infix Operations
---------------------------------------------

```raku
# Sample Raku code
my $code = q{
    for ^10 {
        if $_ %% 2 {
            say 1 * 3;
        }
    }
};

# Generate the AST
my $ast = $code.AST;

# Query to find 'apply-op' nodes where left=1 and right=3
my $result = $ast.&ast-query('.apply-op[left=1, right=3]');
say $result.list;  # Outputs matching 'ApplyOp' nodes
```

### Output

```raku
[
  RakuAST::ApplyInfix.new(
    left  => RakuAST::IntLiteral.new(1),
    infix => RakuAST::Infix.new("*"),
    right => RakuAST::IntLiteral.new(3)
  )
]
```

Explanation:

  * The query `.apply-op[left=1, right=3]` matches ApplyOp nodes with left operand 1 and right operand 3.

Example 2: Using the Ancestor Operator `<<<` and Named Captures
---------------------------------------------------------------

```raku
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

# Query to find 'Infix' nodes with any ancestor 'conditional', and capture 'IntLiteral' nodes with value 2
my $result = $ast.&ast-query('RakuAST::Infix <<< .conditional$cond .int#2$int');
say $result.list;  # Outputs matching 'Infix' nodes
say $result.hash;  # Outputs captured nodes under 'cond' and 'int'
```

### Output

```raku
[
  RakuAST::Infix.new("%%"),
  RakuAST::Infix.new("*")
]
{
  cond => [
    RakuAST::Statement::If.new(
      condition => RakuAST::ApplyInfix.new(
        left  => RakuAST::Var::Lexical.new("$_"),
        infix => RakuAST::Infix.new("%%"),
        right => RakuAST::IntLiteral.new(2)
      ),
      then => RakuAST::Block.new(...)
    )
  ],
  int => [
    RakuAST::IntLiteral.new(2),
    RakuAST::IntLiteral.new(2)
  ]
}
```

Explanation:

  * The query `RakuAST::Infix <<< .conditional$cond .int#2$int`:

  * Matches Infix nodes that have an ancestor matching `.conditional$cond`, regardless of intermediate nodes.

  * Captures IntLiteral nodes with value 2 as $int.

  * Access the captured nodes using $result<cond> and $result<int>.

Example 3: Using the Ancestor Operator `<<` with Ignorable Nodes
----------------------------------------------------------------

```raku
# Find 'Infix' nodes with an ancestor 'conditional', skipping only ignorable nodes
my $result = $ast.&ast-query('RakuAST::Infix << .conditional$cond');
say $result.list;  # Outputs matching 'Infix' nodes
say $result.hash;  # Outputs captured 'conditional' nodes
```

Explanation:

  * The query RakuAST::Infix << .conditional$cond:

  * Matches Infix nodes that have an ancestor .conditional$cond, with only ignorable nodes between them.

  * Captures the conditional nodes as $cond.

Example 4: Using the Parent Operator < and Capturing Nodes
----------------------------------------------------------

```raku
# Sample Raku code
my $code = q{
    for ^10 {
        if $_ %% 2 {
            say $_ * 2;
        }
    }
};

# Generate the AST
my $ast = $code.AST;

# Query to find 'ApplyInfix' nodes where right operand is 2 and capture them as '$op'
my $result = $ast.&ast-query('RakuAST::Infix < .apply-op[right=2]$op');
say $result<op>;  # Captured 'ApplyInfix' nodes
```

### Output

```raku
[
  RakuAST::ApplyInfix.new(
    left  => RakuAST::Var::Lexical.new("$_"),
    infix => RakuAST::Infix.new("*"),
    right => RakuAST::IntLiteral.new(2)
  )
]
```

Explanation:

  * The query `RakuAST::Infix < .apply-op[right=2]$op`:

  * Matches ApplyOp nodes with right operand 2 whose parent is an Infix node.

  * Captures the ApplyOp nodes as $op.

Example 5: Using the Descendant Operator `>>>` and Capturing Variables
----------------------------------------------------------------------

```raku
# Sample Raku code
my $code = q{
    for ^10 {
        if $_ %% 2 {
            say $_;
        }
    }
};

# Generate the AST
my $ast = $code.AST;

# Query to find 'call' nodes that have a descendant 'Var' node and capture the 'Var' node as '$var'
my $result = $ast.&ast-query('.call >>> RakuAST::Var$var');
say $result.list;  # Outputs matching 'call' nodes
say $result.hash;  # Outputs the 'Var' node captured as 'var'
```

### Output

```raku
[
  RakuAST::Call::Name::WithoutParentheses.new(
    name => RakuAST::Name.from-identifier("say"),
    args => RakuAST::ArgList.new(
      RakuAST::Var::Lexical.new("$_")
    )
  )
]
{ var => RakuAST::Var::Lexical.new("$_") }
```

Explanation:

  * The query `.call >>> RakuAST::Var$var`:

  * Matches call nodes that have a descendant Var node, regardless of intermediate nodes.

  * Captures the Var node as $var.

  * Access the captured Var node using $result<var>.

RETRIEVING MATCHED NODES
========================

The ast-query function returns an ASTQuery object with:

  * `@.list`: Matched nodes.

  * `%.hash`: Captured nodes.

Accessing captured nodes:

```raku
# Perform the query
my $result = $ast.&ast-query('.call#say$call');

# Access the captured node
my $call_node = $result<call>;

# Access all matched nodes
my @matched_nodes = $result.list;
```

THE ast-query FUNCTION
======================

Usage:

    :lang<raku> my $result = $ast.&ast-query('query string');

Returns an ASTQuery object with matched nodes and captures.

GET INVOLVED
============

Visit the [ASTQuery repository](https://github.com/FCO/ASTQuery) on GitHub for examples, updates, and contributions.

How You Can Help
----------------

  * Feedback: Share your thoughts on features and usability.

  * Code Contributions: Add new features or fix bugs.

  * Documentation: Improve tutorials and guides.

Note: ASTQuery is developed by Fernando Corrêa de Oliveira.

DEBUG
=====

For debugging, use the `ASTQUERY_DEBUG` env var.

![Trace example](./trace.png)

CONCLUSION
==========

ASTQuery empowers developers to effectively query and manipulate Raku’s ASTs, enhancing code analysis and transformation capabilities.

DESCRIPTION
===========

ASTQuery is a way to match RakuAST

AUTHOR
======

Fernando Corrêa de Oliveira <fernandocorrea@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2024 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

