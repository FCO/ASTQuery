use ASTQuery::Grammar;
use ASTQuery::Actions;
use ASTQuery::Matcher;
use ASTQuery::Match;
unit module ASTQuery;

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

# Register function matchers
multi sub new-function(Str:D $name, Callable:D $fn) is export {
	ASTQuery::Matcher.add-function($name, $fn)
}

multi sub new-function(Str:D $name, ASTQuery::Matcher:D $matcher) is export {
	ASTQuery::Matcher.add-function($name, $matcher)
}

multi sub new-function(Str:D $name, Str:D $selector) is export {
	ASTQuery::Matcher.add-function($name, ast-matcher($selector))
}

multi sub new-function(Pair:D $p) is export {
	new-function($p.key, $p.value)
}

# Built-in function matchers (registered at module load)
# Naming uses '&...' to mirror query syntax
# Simple kind checks use Callables to avoid early matcher pitfalls
new-function('&is-call'            => -> $n { $n.^name.starts-with('RakuAST::Call') });
new-function('&is-operator'        => -> $n { $n.^name ~~ /Infix|Prefix|Postfix/ });
new-function('&is-apply-operator'  => -> $n { $n.^name ~~ /Apply(Infix|ListInfix|Postfix)|Ternary/ });
new-function('&is-assignment'      => -> $n { $n.^name.contains('Assignment') || $n.^name.starts-with('RakuAST::Initializer::') });
new-function('&is-conditional'     => -> $n { $n.^name.contains('Statement::If') || $n.^name.contains('Statement::Unless') || $n.^name.contains('Statement::With') || $n.^name.contains('Statement::Without') });

# Descendant presence checks via a one-off match on descendants-only
new-function('&has-var'  => -> $n { ASTQuery::Match.new(:ast($n), :matcher(ast-matcher('.variable-usage'))).query-descendants-only.so });
new-function('&has-call' => -> $n { ASTQuery::Match.new(:ast($n), :matcher(ast-matcher('.call'))).query-descendants-only.so });
new-function('&has-int'  => -> $n { ASTQuery::Match.new(:ast($n), :matcher(ast-matcher('.int'))).query-descendants-only.so });

=begin pod

=head1 NAME

ASTQuery - Query and manipulate Raku’s Abstract Syntax Trees (RakuAST) with an expressive syntax

=head1 INSTALLATION

=begin itemized

=item Install dependencies (without running tests): C<zef install --/test --test-depends --deps-only .>

=item Optional tools: C<zef install --/test App::Prove6>, C<zef install --/test App::RaCoCo>

=end itemized

=head1 QUICKSTART

=begin code :lang<raku>
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
=end code

=head1 DESCRIPTION

ASTQuery provides a compact, composable query language for traversing and matching nodes in
Raku’s RakuAST. It lets you precisely match nodes, relationships (child/descendant/ancestor), and
attributes, capture interesting nodes, and register custom function matchers for reuse.

=head2 Key Features

=begin itemized

=item Expressive Query Syntax: Define complex queries to match specific AST nodes.
=item Relationship Operators: Parent/child, ancestor/descendant, and ignorable-skipping variants.
=item Named Captures: Capture matched nodes for easy retrieval.
=item Attribute Matching: Compare values, traverse attributes, and run regexes.
=item Custom Functions: Register reusable matchers referenced with C<&name> in queries.
=item CLI Utility: Query files on disk and print results in a readable form.

=end itemized

=head1 CLI

=begin itemized

=item Run against a directory or a single file: C<raku -I. bin/ast-query.raku 'SELECTOR' [path]>

=item If C<path> is omitted, scans the current directory recursively.

=item Scans extensions: C<raku>, C<rakumod>, C<rakutest>, C<rakuconfig>, C<p6>, C<pl6>, C<pm6>.

=item Example: C<raku -I. bin/ast-query.raku '.call#say >>> .int' lib/>

=end itemized

=head1 QUERY LANGUAGE SYNTAX

=head2 Node Description

Format:

C<RakuAST::Class::Name.group#id[attr1, attr2=attrvalue]$name&function>

Components:

=begin itemized

=item C<RakuAST::Class::Name>: (Optional) Full class name.
=item C<.group>: (Optional) Node group (predefined; see Groups).
=item C<#id>: (Optional) Identifier value compared against the node’s id field.
=item C<[attributes]>: (Optional) Attribute matchers.
=item C<$name>: (Optional) Capture name (only one per node part).
=item C<&function>: (Optional) Apply a registered function matcher; multiple compose with AND.

=end itemized

=head2 Operators

=begin itemized

=item C<E<gt>>  : Left node has the right node as a child.
=item C<E<gt>E<gt>> : Left node has the right node as a descendant, with only ignorable nodes between.
=item C<E<gt>E<gt>E<gt>>: Left node has the right node as a descendant (any nodes in between).
=item C<E<lt>>  : Right node is the parent of the left node.
=item C<E<lt>E<lt>> : Right node is an ancestor of the left node, with only ignorable nodes between.
=item C<E<lt>E<lt>E<lt>>: Right node is an ancestor of the left node (any nodes in between).

=end itemized

Note: The space operator is no longer used.

=head2 Attribute Relation Operators

Start traversal from the attribute node (when the attribute value is itself a RakuAST node):

=begin itemized

=item C<[attr=E<gt> MATCH]>     — Child relation from the attribute node to MATCH.
=item C<[attr=E<gt>E<gt> MATCH]>    — Descendant via ignorable nodes.
=item C<[attr=E<gt>E<gt>E<gt> MATCH]>   — Descendant allowing any nodes.

=end itemized

=head2 Attribute Value Operators

Inside C<[attributes]> you can apply value operators to an attribute, comparing against a literal string/number,
identifier, or a regex literal:

=begin itemized

=item C<[attr~= value]> — Contains: substring or regex match on the attribute’s leaf value
=item C<[attr^= value]> — Starts-with
=item C<[attr$= value]> — Ends-with
=item C<[attr*=/regex/]> — Regex match using C</.../> literal

=end itemized

When the attribute value is a RakuAST node, the matcher walks nested nodes via their configured id fields to
reach a comparable leaf value (e.g., C<.call[name]> → Name’s identifier). Non-existent attributes never match.
Flags in regex literals are not yet supported.

=head2 Ignorable Nodes

Nodes skipped by C<E<gt>E<gt>> and C<E<lt>E<lt>> operators:

=begin itemized

=item C<RakuAST::Block>
=item C<RakuAST::Blockoid>
=item C<RakuAST::StatementList>
=item C<RakuAST::Statement::Expression>
=item C<RakuAST::ArgList>

=end itemized

=head1 Function Matchers (C<&name>)

Register reusable matchers in code and reference them in queries via C<&name>.
Functions compose with other constraints using AND semantics.

=begin itemized

=item From a selector string: C<new-function('&has-int' => 'RakuAST::Node >>> .int')>

=item From a compiled matcher: C<new-function '&f-call', ast-matcher('.call#f')>

=item From a Callable: C<new-function('&int-is-2' => -> $n { $n.^name eq 'RakuAST::IntLiteral' && $n.value == 2 })>

=end itemized

Built-ins registered on module load:

=begin itemized

=item C<&is-call>, C<&is-operator>, C<&is-apply-operator>
=item C<&is-assignment>, C<&is-conditional>
=item C<&has-var>, C<&has-call>, C<&has-int>

=end itemized

=head1 Groups (Common Aliases)

=begin itemized

=item C<.call> → C<RakuAST::Call>
=item C<.apply-operator> → C<RakuAST::ApplyInfix|ApplyListInfix|ApplyPostfix|Ternary>
=item C<.operator> → C<RakuAST::Infixish|Prefixish|Postfixish>
=item C<.conditional> → C<RakuAST::Statement::IfWith|Unless|Without>
=item C<.variable>, C<.variable-usage>, C<.variable-declaration>
=item C<.statement>, C<.expression>, C<.int>, C<.str>, C<.ignorable>

=end itemized

You can extend these with C<add-ast-group> and C<add-to-ast-group>.

=head1 AST TRANSFORMATIONS

Use ASTQuery in a C<CHECK> phaser to rewrite the current compilation unit’s AST before runtime.

=begin itemized

=item Prereqs: C<use experimental :rakuast;>

=item Obtain the tree with C<$*CU.AST>, mutate nodes, optionally assign back with C<$*CU.AST = $ast>.

=end itemized

=head2 Example: Replace C<say> with C<note>

=begin code :lang<raku>
use experimental :rakuast;
use ASTQuery;

CHECK {
    my $ast = $*CU.AST;
    my $m = $ast.&ast-query('.call#say$call');
    for $m<call> -> $call {
        CATCH { default { note "say->note rewrite failed: $_" } }
        try $call.name = RakuAST::Name.from-identifier('note');
    }
    $*CU.AST = $ast;
}
=end code

=head2 Example: Change operator C<*> to C<+>

=begin code :lang<raku>
use experimental :rakuast;
use ASTQuery;

CHECK {
    my $ast = $*CU.AST;
    my $ops = $ast.&ast-query('.apply-operator[infix => RakuAST::Infix#*]$app');
    for $ops<app> -> $app {
        CATCH { default { note "operator rewrite failed: $_" } }
        try $app.infix = RakuAST::Infix.new('+');
    }
    $*CU.AST = $ast;
}
=end code

=note RakuAST remains experimental; if a field is not C<rw> on your Rakudo, rebuild the enclosing node as a fallback.

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

# Query to find 'apply-operator' nodes where left=1 and right=3
my $result = $ast.&ast-query('.apply-operator[left=1, right=3]');
say $result.list;  # Outputs matching nodes
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

=item The query C<.apply-operator[left=1, right=3]> matches Apply* nodes with left operand 1 and right operand 3.

=head2 Example 2: Using the Ancestor Operator C<E<lt>E<lt>E<lt>> and Named Captures

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
say $result.list;  # Infix nodes
say $result.hash;  # Captured nodes under 'cond' and 'int'

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

=item The query C«RakuAST::Infix <<< .conditional$cond .int#2$int» matches Infix nodes that have an ancestor matching C<.conditional$cond>, regardless of intermediate nodes, and captures C<IntLiteral> nodes with value 2 as C<$int>.

=head2 Example 3: Using the Ancestor Operator C<E<lt>E<lt>> with Ignorable Nodes

=begin code :lang<raku>

# Find 'Infix' nodes with an ancestor 'conditional', skipping only ignorable nodes
my $result = $ast.&ast-query('RakuAST::Infix << .conditional$cond');
say $result.list;  # Infix nodes
say $result.hash;  # Captured 'conditional' nodes

=end code

Explanation:

=item The query C«RakuAST::Infix << .conditional$cond» matches Infix nodes that have an ancestor C<.conditional$cond>, with only ignorable nodes between them.

=head2 Example 4: Using the Parent Operator C<E<lt>> and Capturing Nodes

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
my $result = $ast.&ast-query('RakuAST::Infix < .apply-operator[right=2]$op');
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

=item The query C<< RakuAST::Infix < .apply-operator[right=2]$op >> matches Apply* nodes with right operand 2 whose parent is an C<Infix> node and captures them as C<$op>.

=head2 Example 5: Using the Descendant Operator C<E<gt>E<gt>E<gt>> and Capturing Variables

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
say $result.list;  # call nodes
say $result.hash;  # 'Var' node captured as 'var'

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

=item The query C<< .call >>> RakuAST::Var$var >> matches call nodes that have a descendant C<Var> node, regardless of intermediate nodes, and captures the C<Var> node as C<$var>.

=head1 RETRIEVING MATCHED NODES

The C<ast-query> function returns an C<ASTQuery::Match> object with:

=begin itemized

=item C<@.list>: Matched nodes.
=item C<%.hash>: Captured nodes.

=end itemized

Accessing captured nodes:

=begin code :lang<raku>
# Perform the query
my $result = $ast.&ast-query('.call#say$call');

# Access the captured node
my $call_node = $result<call>;

# Access all matched nodes
my @matched_nodes = $result.list;
=end code

=head1 PROGRAMMATIC API

=begin itemized

=item C<ast-query($ast, Str $selector)> and C<ast-query($ast, $matcher)> — run a query over a RakuAST and return C<ASTQuery::Match>.

=item C<ast-matcher(Str $selector)> — compile a selector into a matcher object for reuse.

=item C<new-function($name, $callable|$matcher|$selector)> — register a function matcher usable as C<&name>.

=item C<add-ast-group($name, @classes)> / C<add-to-ast-group($name, *@classes)> — create or extend group aliases.

=item C<set-ast-id($class, $id-method)> — configure which attribute is considered the node’s id field.

=end itemized

=head1 GET INVOLVED

Visit the L<ASTQuery repository|https://github.com/FCO/ASTQuery> on GitHub for examples, updates, and contributions.

=head2 How You Can Help

=begin itemized

=item Feedback: Share your thoughts on features and usability.
=item Code Contributions: Add new features or fix bugs.
=item Documentation: Improve tutorials and guides.

=end itemized

Note: ASTQuery is developed by Fernando Corrêa de Oliveira.

=head1 DEBUG

Set the C<ASTQUERY_DEBUG> env var to see a tree of matcher decisions and deparsed node snippets.

![Trace example](./trace.png)

=head1 CONCLUSION

ASTQuery empowers developers to effectively query and manipulate Raku’s ASTs, enhancing code analysis and transformation capabilities.

=head1 AUTHOR

Fernando Corrêa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2024 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
