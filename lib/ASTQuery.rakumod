use experimental :rakuast;
unit class ASTQuery;

sub term:<ast-true> is export {RakuAST::Term::Name.new( RakuAST::Name.from-identifier("True"))}

class ASTType {
	has ::?CLASS @.opts handles <elems AT-POS map>;
	has Any $.type;
	has Str $.main-param;

	method gist {"ASTType: {$!type.^name}"}
	method Str { self.gist }
}

class MultiValue {}
enum ASTTypeOption is export (
	call        => ASTType.new(:type(RakuAST::Call), :main-param<name>),
	expression  => ASTType.new(:type(RakuAST::Statement::Expression), :main-param<expression>),
	statement   => ASTType.new(:type(RakuAST::Statement)),
	conditional => ASTType.new(:type(MultiValue), :opts[
		ASTType.new(:type(RakuAST::Statement::IfWith), :main-param<condition>),
		ASTType.new(:type(RakuAST::Statement::Unless), :main-param<condition>),
	]),
	int         => ASTType.new(:type(RakuAST::IntLiteral)),
);

has ASTType $.type;

method ACCEPTS($node) {
	return self.Multi::validate($node) if $!type.defined && $!type.type =:= MultiValue;
	my $ans = [&&] self.+validate($node);
	say "{self.^name}: ACCEPTS: $ans" if %*ENV<ASTQUERY_DEBUG>;
	$ans
}

method validate($node) {
	say "validate type: $node.^name() { $node.DEPARSE } ~~ {.type.^name with $!type}" if %*ENV<ASTQUERY_DEBUG>;
	my $ans = !$!type.defined || $node ~~ $!type.type;
	say "type: $ans" if %*ENV<ASTQUERY_DEBUG>;
	$ans
}

role Multi {
	has $.candidates;
	method validate($node) {
		#say "validate Multi: $node.^name() { $node.DEPARSE }" if %*ENV<ASTQUERY_DEBUG>;
		my $ans = [False, |$!candidates[]].reduce: -> $ans, $can {
			$ans || $can.ACCEPTS: $node;
		}
		say "Multi: $ans" if %*ENV<ASTQUERY_DEBUG>;
		$ans
	}
}

role HasIntValue {
	has Int $.value;
	method validate($node) {
		say "validate IntValue: $node.^name() { $node.DEPARSE }" if %*ENV<ASTQUERY_DEBUG>;
		say $node, " eqv ", RakuAST::IntLiteral.new($!value) if %*ENV<ASTQUERY_DEBUG>;
		my $ans = $node eqv RakuAST::IntLiteral.new($!value);
		say "HasIntValue: $ans" if %*ENV<ASTQUERY_DEBUG>;
		$ans
	}
}

role HasName {
	has Str $.name;
	method validate($node) {
		#say "validate Name: $node.^name() { $node.DEPARSE }" if %*ENV<ASTQUERY_DEBUG>;
		my $ans = $node.^can("name") && $node.name eqv RakuAST::Name.from-identifier($!name);
		say "HasName: $ans" if %*ENV<ASTQUERY_DEBUG>;
		$ans
	}
}

role HasCondition {
	has $.condition;
	method validate($node) {
		#say "validate Condition: $node.^name() { $node.DEPARSE }" if %*ENV<ASTQUERY_DEBUG>;
		my $ans = $node.^can("condition") && $node.condition eqv $!condition;
		say "HasCondition: $ans" if %*ENV<ASTQUERY_DEBUG>;
		$ans
	}
}

role Children {
	has $.children;
	method validate($node) {
		say "validate Children: $node.^name() { $node.DEPARSE }" if %*ENV<ASTQUERY_DEBUG>;
		my $num = $!children.elems;
		my @sub = gather {$node.visit-children: &take}.head: $num;
		say @sub if %*ENV<ASTQUERY_DEBUG>;
		say $!children[] if %*ENV<ASTQUERY_DEBUG>;
		return False unless @sub == $num;

		my $ans = [&&] ($num > 0), |(@sub Z[~~] $!children[]);
		say "Children: $ans" if %*ENV<ASTQUERY_DEBUG>;
		$ans
	}
}

proto ast-query(|c) is export {*}

multi ast-query(ASTType $ast-type, **@params) is default {
	my $obj = ::?CLASS.new: :type($ast-type);
	return $obj unless @params;
	ast-query :$obj, |@params
}

multi ast-query(ASTTypeOption $enum where {.value.opts.elems > 1}, **@params) {
	my $type = $enum.value;
	my $obj = ::?CLASS.new: :$type;
	$obj but Multi(
		@=$enum.value.opts.map: {
			ast-query $_, |@params;
		}
	);
}

multi ast-query(ASTTypeOption $enum where {.value.elems == 1}, **@params) {
	ast-query $enum.value, |@params;
}

multi ast-query(Str $name, **@params, :$obj is copy where *.type.main-param eq "name" = ::?CLASS.new) {
	$obj = $obj but HasName($name);
	return $obj unless @params;
	ast-query :$obj, |@params
}

multi ast-query(RakuAST::Term $condition, **@params, :$obj is copy where *.type.main-param eq "condition" = ::?CLASS.new) {
	$obj = $obj but HasCondition($condition);
	return $obj unless @params;
	ast-query :$obj, |@params
}

multi ast-query(@children where {.are: ::?CLASS}, **@params, :$obj is copy = ::?CLASS.new) {
	$obj = $obj but Children(@children);
	return $obj unless @params;
	ast-query :$obj, |@params
}

multi ast-query(Int $value, **@params, :$obj is copy = ::?CLASS.new: :type(ASTTypeOption::int.value)) {
	$obj = $obj but HasIntValue($value);
	return $obj unless @params;
	ast-query :$obj, |@params
}

=begin pod

=head1 NAME

ASTQuery - blah blah blah

=head1 SYNOPSIS

=begin code

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

=end code

=head1 DESCRIPTION

ASTQuery is a way to match RakuAST

=head1 AUTHOR

Fernando Corrêa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2024 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
