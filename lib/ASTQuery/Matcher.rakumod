use experimental :rakuast;
unit class ASTQuery::Matcher;

my %groups is Map = (
	call       => [RakuAST::Call],
	expression => [RakuAST::Statement::Expression],
	statement   => [RakuAST::Statement],
	int         => [RakuAST::IntLiteral],
	op          => [
		RakuAST::Infixish,
		RakuAST::Prefixish,
		RakuAST::Postfixish,
	],
	apply-op    => [
		RakuAST::ApplyInfix,
		RakuAST::ApplyListInfix,
		RakuAST::ApplyDottyInfix,
		RakuAST::ApplyDottyInfix,
		RakuAST::ApplyPostfix,
		RakuAST::Ternary,
	],
	conditional => [
		RakuAST::Statement::IfWith,
		RakuAST::Statement::Unless,
	],
);

my %id is Map = (
	"RakuAST::Call"                           => "name",
	"RakuAST::Statement::Expression"          => "expression",
	"RakuAST::Statement::IfWith"              => "condition",
	"RakuAST::Statement::Unless"              => "condition",
	"RakuAST::Literal"                        => "value",
	"RakuAST::Name"                           => "simple-identifier",
	"RakuAST::Term::Name"                     => "name",
	"RakuAST::ApplyInfix"                     => "infix",
	"RakuAST::Infixish"                       => "infix",
	"RakuAST::Infix"                          => "operator",
	"RakuAST::Prefix"                         => "operator",
	"RakuAST::Postfix"                        => "operator",
	"RakuAST::ApplyInfix"                     => "infix",
	"RakuAST::ApplyListInfix"                 => "infix",
	"RakuAST::ApplyDottyInfix"                => "infix",
	"RakuAST::ApplyPostfix"                   => "postfix",
	"RakuAST::FunctionInfix"                  => "function",
	"RakuAST::ArgList"                        => "args",
);

method get-id-field($node) {
	for $node.^mro {
		.return with %id{.^name}
	}
}

has Str $.class;
has Str $.group where { %groups{$_} };
has $.id;
has %.atts;
has %.params;

method ACCEPTS($node) {
	my $key = $.get-id-field: $node;
	so ($!class ?? $.validate-class($node, $!class)                        !! True)
	&& ($!group ?? $.validate-class($node, |%groups{$!group})              !! True)
	&& ($!id    ?? $key.defined && $.validate-atts($node, %($key => $!id)) !! True)
	&& (%!atts  ?? $.validate-atts($node, %!atts)                          !! True)
	# TODO: params
}

method validate-class($node, **@classes) {
	[False, |@classes].reduce: -> $ans, $class {
		$ans || $node ~~ $class
	};
}

method validate-atts($node, %atts) {
	[True, |%atts.pairs].reduce: -> $ans, (:$key, :$value) {
		$ans && $.validate-value: $node, $key, $value
	}
}

method validate-value($node, $key, $value) {
	do if $node.^name.starts-with("RakuAST") && !$value.^name.starts-with: "RakuAST" {
		return False unless $key;
		my $nnode = $node."$key"();
		$.validate-value: $nnode, $.get-id-field($nnode), $value
	} else { 
		$node ~~ $value
	}
}
