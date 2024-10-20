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
);

has ASTType $.type;

method ACCEPTS($node) {
	return self.Multi::validate($node) if $!type.type =:= MultiValue;
	[&&] self.+validate($node);
}

method validate($node) {
	$!type.defined && $node ~~ $!type.type;
}

role Multi {
	has $.candidates;
	method validate($node) {
		[False, |$!candidates[]].reduce: -> $ans, $can {
			$ans || $can.ACCEPTS: $node;
		}
	}
}

role HasName {
	has Str $.name;
	method validate($node) {
		$node.^can("name") && $node.name eqv RakuAST::Name.from-identifier($!name);
	}
}

role HasCondition {
	has $.condition;
	method validate($node) {
		$node.^can("condition") && $node.condition eqv $!condition;
	}
}

role Children {
	has $.children;
	method validate($node) {
		my $num = $!children.elems;
		my @sub = gather {$node.visit-children: &take}.head: $num;
		return False unless @sub == $num;

		[&&] ($num > 0), |(@sub Z[~~] $!children[]);
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

=begin pod

=head1 NAME

ASTQuery - blah blah blah

=head1 SYNOPSIS

=begin code :lang<raku>

use ASTQuery;

=end code

=head1 DESCRIPTION

ASTQuery is ...

=head1 AUTHOR

Fernando Corrêa de Oliveira <fernandocorrea@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2024 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
