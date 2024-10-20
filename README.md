[![Actions Status](https://github.com/FCO/ASTQuery/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/ASTQuery/actions)

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

