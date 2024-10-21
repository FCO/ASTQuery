[![Actions Status](https://github.com/FCO/ASTQuery/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/ASTQuery/actions)
# ASTQuery

ASTQuery is a Raku module designed to simplify the process of querying and manipulating Raku's Abstract Syntax Trees (RakuAST). It provides a declarative and intuitive way to match and transform AST nodes, making it easier for developers to analyze, refactor, and understand Raku code at a deeper level.

## Key Features

- **Declarative AST Matching**: Write concise queries to match RakuAST nodes without dealing with the complexities of the underlying structures.
- **Flexible Query Language**: Utilize typical Raku statements or a specialized Domain-Specific Language (DSL) to express queries. The syntax is still under exploration, with considerations for CSS-like selectors.
- **AST Modification**: Not only query but also modify the AST, enabling powerful code transformations and refactoring tools.
- **Simplified Node Matching**: Optionally ignore intermediary nodes like `statementlist` to make pattern matching more straightforward.
- **Tool Integration**: Designed to be used with tools like `rak` for searching and analyzing code across files.
- **Code Analysis Modules**: Potential to build modules that can detect common pitfalls or [traps](https://docs.raku.org/language/traps) in Raku code.

## Motivation

While Raku allows direct manipulation of RakuAST, ASTQuery aims to make this process simpler and more declarative. By reducing the verbosity and complexity, developers can focus on what they want to match or transform without getting bogged down by the mechanics of AST traversal.

### Why Not Plain Raku?

- **Simplicity**: ASTQuery abstracts the repetitive patterns involved in AST manipulation.
- **Declarative Approach**: Focus on *what* to match rather than *how* to traverse the AST.
- **Readability**: Cleaner syntax makes queries easier to read and maintain.

## Potential Use Cases

- **Learning Tool**: Helps developers understand Raku's syntax trees and how the language works under the hood.
- **Language Tooling**: Assists in creating new language implementations, linters, or code formatters.
- **Code Search**: Enables advanced code searches in projects, useful for refactoring or analysis.
- **Trap Detection**: Build modules to automatically warn about common mistakes or traps in Raku code.

## Example Usage

### Matching an Infix Expression with an Integer Left Operand

Using a hypothetical query syntax:

```raku
ast-query infix, :left[ast-query number]
```

This matches any `infix` node where the left child is a `number` node. The goal is to make such queries intuitive and expressive.

### Ignoring Intermediate Nodes

To match an `if` statement with an assignment as the first line without worrying about intermediate `statementlist` nodes:

```raku
ast-query if, :body[ast-query assignment]
```

## Current Status

The project is in an exploratory phase. Key aspects like the query language syntax are still being decided. Contributions, suggestions, and feedback are highly welcome.

## Future Directions

- **Finalize Query Syntax**: Decide between using typical Raku statements, a new DSL, or a combination thereof.
- **Enhance AST Manipulation**: Improve capabilities to modify ASTs for code transformation tasks.
- **Tooling Integration**: Work towards seamless integration with development tools like `rak`.
- **Extend Use Cases**: Explore building additional modules for code analysis, refactoring, and more.

## Get Involved

Check out the [ASTQuery repository](https://github.com/FCO/ASTQuery) on GitHub for code examples and the latest updates. Feel free to open issues, submit pull requests, or join the discussion to help shape the future of ASTQuery.

---

*Note: ASTQuery is a project by Fernando Corrêa de Oliveira, aimed at making AST manipulation in Raku more accessible and powerful.*

NAME
====

ASTQuery - blah blah blah

SYNOPSIS
========

    ❯ raku -Ilib -MASTQuery -e 'use experimental :rakuast; say Q|unless True { say 42 }|.AST.grep: ast-query [ast-query 42]'
    (RakuAST::ArgList.new(
      RakuAST::IntLiteral.new(42)
    ))
    ❯ raku -Ilib -MASTQuery -e 'use experimental :rakuast; say Q|unless True { say 42 }|.AST.grep: ast-query conditional'
    (RakuAST::Statement::Unless.new(
      condition => RakuAST::Term::Name.new(
        RakuAST::Name.from-identifier("True")
      ),
      body      => RakuAST::Block.new(
        body => RakuAST::Blockoid.new(
          RakuAST::StatementList.new(
            RakuAST::Statement::Expression.new(
              expression => RakuAST::Call::Name::WithoutParentheses.new(
                name => RakuAST::Name.from-identifier("say"),
                args => RakuAST::ArgList.new(
                  RakuAST::IntLiteral.new(42)
                )
              )
            )
          )
        )
      )
    ))
    ❯ raku -Ilib -MASTQuery -e 'use experimental :rakuast; say Q|unless True { say 42 }|.AST.grep: ast-query call, "say"'
    (RakuAST::Call::Name::WithoutParentheses.new(
      name => RakuAST::Name.from-identifier("say"),
      args => RakuAST::ArgList.new(
        RakuAST::IntLiteral.new(42)
      )
    ))

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

