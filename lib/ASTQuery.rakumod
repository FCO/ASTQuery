use ASTQuery::Grammar;
use ASTQuery::Actions;
use ASTQuery::Matcher;
use ASTQuery::Match;
#unit class ASTQuery;

proto ast-query($, $) is export {*}

multi ast-query($ast, Str $selector) {
	my $matcher = ast-matcher $selector;
	ast-query $ast, $matcher
}

multi ast-query($ast, $matcher) {
	my $match = ASTQuery::Match.new:
		:$ast,
		:$matcher,
	;
	$match.query || Empty;
}

sub ast-matcher(Str $selector) is export {
	ASTQuery::Grammar.parse($selector, :actions(ASTQuery::Actions)).made
}

sub add-ast-group(|c) is export {ASTQuery::Matcher.add-ast-group: |c}
sub add-to-ast-group(|c) is export {ASTQuery::Matcher.add-to-ast-group: |c}
sub set-ast-id(|c) is export {ASTQuery::Matcher.set-ast-id: |c}

=begin pod

=head1 NAME

ASTQuery - Query and manipulate Raku’s Abstract Syntax Trees (RakuAST) with an expressive syntax

=head1 SYNOPSIS

=begin code :lang<raku>
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
=end code

=head2 Output

=begin code :lang<raku>
[
  RakuAST::ApplyInfix.new(
    left  => RakuAST::IntLiteral.new(1),
    infix => RakuAST::Infix.new("*"),
    right => RakuAST::IntLiteral.new(3)
  )
]
=end code

=head1 DESCRIPTION

ASTQuery simplifies querying and manipulating Raku’s ASTs using a powerful query language. It allows precise selection of nodes and relationships, enabling effective code analysis and transformation.

=head2 Key Features

=item Expressive Query Syntax: Define complex queries to match specific AST nodes.
=item Node Relationships: Use operators to specify parent-child and ancestor-descendant relationships.
=item Named Captures: Capture matched nodes for easy retrieval.
=item AST Manipulation: Modify the AST for code transformations and refactoring.

=head1 QUERY LANGUAGE SYNTAX

=head2 Node Description

Format:

C<RakuAST::Class::Name.group#id[attr1, attr2=attrvalue]$name>

Components:

=item C<RakuAST::Class::Name>: (Optional) Full class name.
=item C<.group>: (Optional) Node group (predefined).
=item C<#id>: (Optional) Identifier attribute.
=item C<[attributes]>: (Optional) Attributes to match.
=item C<$name>: (Optional) Capture name.

Note: Use only one $name per node.

=head2 Operators

=item `>` : Left node has the right node as a child.
=item `<` : Right node is the parent of the left node.
=item `>>>`: Left node has the right node as a descendant (any nodes can be between them).
=item `>>`: Left node has the right node as a descendant, with only ignorable nodes in between.
=item `<<<`: Right node is an ancestor of the left node (any nodes can be between them).
=item `<<`: Right node is an ancestor of the left node, with only ignorable nodes in between.

Note: The space operator is no longer used.

=head2 Ignorable Nodes

Nodes skipped by `>>` and `<<` operators:

=item C<RakuAST::Block>
=item C<RakuAST::Blockoid>
=item C<RakuAST::StatementList>
=item C<RakuAST::Statement::Expression>
=item C<RakuAST::ArgList>

=head1 EXAMPLES

=head2 Example 1: Matching Specific Infix Operations

=begin code :lang<raku>

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
=end code

=head3 Output

=begin code :lang<raku>

[
  RakuAST::ApplyInfix.new(
    left  => RakuAST::IntLiteral.new(1),
    infix => RakuAST::Infix.new("*"),
    right => RakuAST::IntLiteral.new(3)
  )
]

=end code

Explanation:

=item The query C<.apply-op[left=1, right=3]> matches ApplyOp nodes with left operand 1 and right operand 3.

=head2 Example 2: Using the Ancestor Operator `<<<` and Named Captures

=begin code :lang<raku>

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

=end code

=head3 Output

=begin code :lang<raku>

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

=end code

Explanation:

=item The query `RakuAST::Infix <<< .conditional$cond .int#2$int`:
=item Matches Infix nodes that have an ancestor matching C<.conditional$cond>, regardless of intermediate nodes.
=item Captures IntLiteral nodes with value 2 as $int.
=item Access the captured nodes using $result<cond> and $result<int>.

=head2 Example 3: Using the Ancestor Operator `<<` with Ignorable Nodes

=begin code :lang<raku>

# Find 'Infix' nodes with an ancestor 'conditional', skipping only ignorable nodes
my $result = $ast.&ast-query('RakuAST::Infix << .conditional$cond');
say $result.list;  # Outputs matching 'Infix' nodes
say $result.hash;  # Outputs captured 'conditional' nodes

=end code

Explanation:

=item The query RakuAST::Infix << .conditional$cond:
=item Matches Infix nodes that have an ancestor .conditional$cond, with only ignorable nodes between them.
=item Captures the conditional nodes as $cond.

=head2 Example 4: Using the Parent Operator < and Capturing Nodes

=begin code :lang<raku>

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

=end code

=head3 Output

=begin code :lang<raku>

[
  RakuAST::ApplyInfix.new(
    left  => RakuAST::Var::Lexical.new("$_"),
    infix => RakuAST::Infix.new("*"),
    right => RakuAST::IntLiteral.new(2)
  )
]

=end code

Explanation:

=item The query `RakuAST::Infix < .apply-op[right=2]$op`:
=item Matches ApplyOp nodes with right operand 2 whose parent is an Infix node.
=item Captures the ApplyOp nodes as $op.

=head2 Example 5: Using the Descendant Operator `>>>` and Capturing Variables

=begin code :lang<raku>

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

=end code

=head3 Output

=begin code :lang<raku>

[
  RakuAST::Call::Name::WithoutParentheses.new(
    name => RakuAST::Name.from-identifier("say"),
    args => RakuAST::ArgList.new(
      RakuAST::Var::Lexical.new("$_")
    )
  )
]
{ var => RakuAST::Var::Lexical.new("$_") }

=end code

Explanation:

=item The query `.call >>> RakuAST::Var$var`:
=item Matches call nodes that have a descendant Var node, regardless of intermediate nodes.
=item Captures the Var node as $var.
=item Access the captured Var node using $result<var>.

=head1 RETRIEVING MATCHED NODES

The ast-query function returns an ASTQuery object with:

=item C<@.list>: Matched nodes.
=item C<%.hash>: Captured nodes.

Accessing captured nodes:

=begin code :lang<raku>
# Perform the query
my $result = $ast.&ast-query('.call#say$call');

# Access the captured node
my $call_node = $result<call>;

# Access all matched nodes
my @matched_nodes = $result.list;

=end code

=head1 THE ast-query FUNCTION

Usage:

=code :lang<raku> my $result = $ast.&ast-query('query string');

Returns an ASTQuery object with matched nodes and captures.

=head1 GET INVOLVED

Visit the L<ASTQuery repository|https://github.com/FCO/ASTQuery> on GitHub for examples, updates, and contributions.

=head2 How You Can Help

=item Feedback: Share your thoughts on features and usability.
=item Code Contributions: Add new features or fix bugs.
=item Documentation: Improve tutorials and guides.

Note: ASTQuery is developed by Fernando Corrêa de Oliveira.

=head1 DEBUG

For debugging, use the C<ASTQUERY_DEBUG> env var.

![Trace example](./trace.png)

=head1 CONCLUSION

ASTQuery empowers developers to effectively query and manipulate Raku’s ASTs, enhancing code analysis and transformation capabilities.

=head1 DESCRIPTION

ASTQuery is a way to match RakuAST

=head1 AUTHOR

Fernando Corrêa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2024 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
