use experimental :rakuast, :will-complain;
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
		#RakuAST::ApplyDottyInfix,
		RakuAST::ApplyPostfix,
		RakuAST::Ternary,
	],
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
	"RakuAST::Name"                  => "simple-identifier",
	"RakuAST::Term::Name"            => "name",
	"RakuAST::ApplyInfix"            => "infix",
	"RakuAST::Infixish"              => "infix",
	"RakuAST::Infix"                 => "operator",
	"RakuAST::Prefix"                => "operator",
	"RakuAST::Postfix"               => "operator",
	"RakuAST::ApplyInfix"            => "infix",
	"RakuAST::ApplyListInfix"        => "infix",
	"RakuAST::ApplyDottyInfix"       => "infix",
	"RakuAST::ApplyPostfix"          => "postfix",
	"RakuAST::FunctionInfix"         => "function",
	"RakuAST::ArgList"               => "args",
);

method get-id-field($node) {
	for $node.^mro {
		.return with %id{.^name}
	}
}

subset ASTClass of Str will complain {"$_ is not a valid class"} where { !.defined || ::(.Str) !~~ Failure }
subset ASTGroup of Str will complain {"$_ is not a valid group"} where { !.defined || %groups{.Str} }

has ASTClass $.class;
has ASTGroup $.group;
has $.id;
has %.atts;
has %.params;
has $.child is rw;
has $.descendent is rw;
has Str $.name;

multi method gist(::?CLASS:D: :$inside = False) {
	"{
		self.^name ~ ".new(" unless $inside
	}{
		.Str with $!class
	}{
		'.' ~ .Str with $!group
	}{
		'#' ~ .Str with $!id
	}{
		"[" ~ %!atts.map(-> $k, $v { $k ~ "=$v.gist()" unless $v =:= Whatever }).join(', ') ~ ']' if %!atts
	}{
		'$' ~ .Str with $!name
	}{
		" > " ~ .gist(:inside) with $!child
	}{
		")" unless $inside
	}"
}

method ACCEPTS($node) {
	#say "ACCEPTS: ", self;
	my $key = self.get-id-field: $node;
	so ($!class ?? self.validate-class($node, ::($!class))                    !! True)
	&& ($!group ?? self.validate-class($node, |%groups{$!group})              !! True)
	&& ($!id    ?? $key.defined && self.validate-atts($node, %($key => $!id)) !! True)
	&& (%!atts  ?? self.validate-atts($node, %!atts)                          !! True)
	&& ($!child ?? self.validate-child($node, $!child)                        !! True)
	# TODO: params
}

method validate-child($node, $child) {
	my $child-match = $*match.new(:ast($node), :matcher($child), :$*match, :ignore-root);
	my $resp = $child-match.query-children-only;
	if $resp.list.elems {
		if $resp.hash {
			$*match.hash.push: $_ for $resp.hash.pairs
		}
		return True
	}
}

method validate-class($node, **@classes) {
	[False, |@classes].reduce: -> $ans, $class {
		$ans || $node ~~ $class
	};
}

method validate-atts($node, %atts) {
	[True, |%atts.pairs].reduce: -> $ans, (:$key, :$value) {
		$ans && self.validate-value: $node, $key, $value
	}
}

method validate-value($node, $key, $value) {
	do if $node.^name.starts-with("RakuAST") && !$value.^name.starts-with: "RakuAST" {
		return False unless $key;
		return False unless $node.^can: $key;
		my $nnode = $node."$key"();
		self.validate-value: $nnode, $.get-id-field($nnode), $value
	} else { 
		$node ~~ $value
	}
}
