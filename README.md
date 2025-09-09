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

Available Groups
----------------

ASTQuery provides comprehensive groups to categorize RakuAST types:

**Core Categories:**
  * `.statement` - All statement types, blocks, and control structures (46 types)
  * `.expression` - Infix, prefix, postfix operations and expressions (13 types)  
  * `.literal` - All literal values: int, str, num, complex, version, etc. (8 types)
  * `.declaration` - Classes, roles, subs, vars, packages, etc. (23 types)

**Specialized Categories:**
  * `.regex` - All regex-related nodes and constructs (92 types)
  * `.data` - Arrays, hashes, pairs, argument lists, etc. (21 types)
  * `.code` - Routines, methods, blocks, thunks, etc. (18 types)
  * `.type` - Type definitions, traits, coercions, etc. (22 types)
  * `.var` - All variable types and declarations (20 types)

**Control Flow:**
  * `.control` - Flow control statements like if/unless/when (6 types)
  * `.conditional` - Conditional statements and expressions (6 types)
  * `.iterable` - Loops and iteration constructs (4 types)

**Language Features:**
  * `.phaser` - BEGIN, END, and other phaser blocks (22 types)
  * `.prefix` - Statement prefixes and prefix operators (20 types)
  * `.postfix` - Postfix operators and constructs (5 types)
  * `.parameter` - Parameters and parameter targets (6 types)

**Meta and Utility:**
  * `.meta` - Meta-programming constructs (5 types)
  * `.metainfix` - Meta-infix operators like hyper, cross, etc. (8 types)
  * `.initializer` - Assignment and initialization constructs (6 types)
  * `.doc` - Documentation and pragma nodes (8 types)
  * `.compile` - Compilation units and compile-time constructs (8 types)
  * `.special` - Terms, stubs, and specialized nodes (29 types)

**Convenience Groups:**
  * `.call` - Call expressions
  * `.int` - Integer literals
  * `.str` - String literals  
  * `.op` - All operator types
  * `.apply-op` - Applied operations
  * `.ignorable` - Nodes skipped by `>>` and `<<` operators

Common ID Attributes
--------------------

The `#id` syntax provides access to key identifying attributes:

**Values and Content:**
  * `#value` - For all literal types (IntLiteral, StrLiteral, etc.)
  * `#text` - For regex literals and quoted content
  * `#literal` - For quoted strings

**Names and Identifiers:**
  * `#name` - For declarations, calls, methods, classes, packages, etc.
  * `#simple-identifier` - For basic names
  * `#desigilname` - For variable names without sigils

**Operators and Operations:**
  * `#operator` - For infix, prefix, postfix operators
  * `#infix` - For infix operations and applications
  * `#prefix` - For prefix applications  
  * `#postfix` - For postfix applications
  * `#function` - For function infix operations

**Control Flow:**
  * `#condition` - For conditionals, loops, and control statements
  * `#topic` - For given statements
  * `#source` - For iteration sources

**Structure:**
  * `#key` - For pairs and named arguments
  * `#target` - For parameters
  * `#type` - For traits and type specifications
  * `#args` - For argument lists
  * `#expression` - For expression statements

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

