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
	ignorable => [
		RakuAST::Block,
		RakuAST::Blockoid,
		RakuAST::StatementList,
		RakuAST::Statement::Expression,
		RakuAST::ArgList,
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
	"RakuAST::Var::Lexical"          => "desigilname",
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
has $.gchild is rw;
has $.parent is rw;
has $.descendant is rw;
has $.ascendant is rw;
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
		"[" ~ %!atts.kv.map(-> $k, $v { $k ~ ( $v =:= Whatever ?? "" !! "=$v.gist()" ) }).join(', ') ~ ']' if %!atts
	}{
		'$' ~ .Str with $!name
	}{
		" > " ~ .gist(:inside) with $!child
	}{
		" >> " ~ .gist(:inside) with $!gchild
	}{
		" < " ~ .gist(:inside) with $!parent
	}{
		" " ~ .gist(:inside) with $!descendant
	}{
		")" unless $inside
	}"
}

method ACCEPTS($node) {
	#say "ACCEPTS: ", self;
	my %*values;
	my $key = self.get-id-field: $node;
	my $ans = so ($!class    ?? self.validate-class($node, ::($!class))                    !! True)
		&& ($!group      ?? self.validate-class($node, |%groups{$!group})              !! True)
		&& ($!id         ?? $key.defined && self.validate-atts($node, %($key => $!id)) !! True)
		&& (%!atts       ?? self.validate-atts($node, %!atts)                          !! True)
		&& ($!child      ?? self.validate-child($node, $!child)                        !! True)
		&& ($!descendant ?? self.validate-descendant($node, $!descendant)              !! True)
		&& ($!gchild     ?? self.validate-gchild($node, $!gchild)                      !! True)
		&& ($!parent     ?? self.validate-parent($node, $!parent)                      !! True)
		&& ($!ascendant  ?? self.validate-ascendant($node, $!ascendant)                !! True)
		# TODO: params
	;

	if $ans {
		for %*values.kv -> $key, $value {
			$*match.hash.push: $key => $value
		}
	}
	return $ans
}

method validate-ascendant($, $parent) {
	[||] do for @*LINEAGE -> $ascendant {
		my $parent-match = $*match.new(:ast($ascendant), :matcher($parent), :$*match);
		my $resp = $parent-match.query-root-only;
		do if $resp.list.elems {
			if $resp.hash {
				for $resp.hash.kv -> $key, $value {
					%*values.push: $key => $value
				}
			}
			True
		}
	}
}

method validate-parent($, $parent) {
	my $parent-match = $*match.new(:ast(@*LINEAGE.head), :matcher($parent), :$*match);
	my $resp = $parent-match.query-root-only;
	if $resp.list.elems {
		if $resp.hash {
			for $resp.hash.kv -> $key, $value {
				%*values.push: $key => $value
			}
		}
		return True
	}
}

method validate-descendant($node, $child) {
	my $descendant-match = $*match.new(:ast($node), :matcher($child), :$*match);
	my $resp = $descendant-match.query-descendants-only;
	if $resp.list.elems {
		if $resp.hash {
			for $resp.hash.kv -> $key, $value {
				%*values.push: $key => $value
			}
		}
		return True
	}
}

method validate-gchild($node, $gchild) {
	my $gchild-result = self.validate-child($node, $gchild);
	return True if $gchild-result;

	my @list = self.query-child($node, ::?CLASS.new: :group<ignorable>);
	[||] do for @list -> $node {
		self.validate-gchild: $node, $gchild
	}
}

method query-child($node, $child, *%pars) {
	my $child-match = $*match.new(:ast($node), :matcher($child), :$*match);
	my $resp = $child-match.query-children-only;
	if $resp.elems {
		if $resp.hash {
			%*values.push: $_ for $resp.hash.pairs
		}
	}
	$resp.list
}

method validate-child($node, $child) {
	self.query-child($node, $child).Bool
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
