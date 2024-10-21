use experimental :rakuast;
unit class ASTQuery::Matcher;

my %groups is Map = (
	call       => [RakuAST::Call],
	expression => [RakuAST::Statement::Expression],
	statement   => [RakuAST::Statement],
	int         => [RakuAST::IntLiteral],
	conditional => [
		RakuAST::Statement::IfWith,
		RakuAST::Statement::Unless,
	],
);

my %id is Map = (
	"RakuAST::Call"                  => "name",
	"RakuAST::Statement::Expression" => "expression",
	"RakuAST::Statement::IfWith"     => "condition",
	"RakuAST::Statement::Unless"     => "condition",
	"RakuAST::Literal"               => "value",
);

has Str $.class;
has Str $.group where { %groups{$_} };
has $.id;
has %.atts;
has %.params;

method ACCEPTS($node) {
	so ($!class ?? $.validate-class($node, $!class)                 !! True)
	&& ($!group ?? $.validate-class($node, |%groups{$!group})       !! True)
	&& (%!atts  ?? $.validate-atts($node, %!atts)                   !! True)
	&& ($!id    ?? $.validate-atts($node, (%id{$node.^name} => $_)) !! True)
	# TODO: params
}

method validate-class($node, **@classes) {
	[False, |@classes].reduce: -> $ans, $class {
		$ans || $node ~~ $class
	};
}

method validate-atts($node, %atts) {
	[True, |%!atts.pairs].reduce: -> $ans, (:$key, :$value) {
		$ans && $.validate-value: $node, $key, $value
	}
}

method validate-value($node, $key, $value) {
	do if $node.^name.starts-with: "RakuAST" && !$value.^name.starts-with: "RakuAST" {
		$node."$key"() ~~ $value
	} else { 
		$node ~~ $value
	}
}
