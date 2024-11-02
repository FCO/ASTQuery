use experimental :rakuast, :will-complain;
use ASTQuery::Match;
unit class ASTQuery::Matcher;

my $DEBUG = %*ENV<ASTQUERY_DEBUG>;

my %groups is Map = (
	call       => [RakuAST::Call],
	expression => [RakuAST::Statement::Expression],
	statement   => [RakuAST::Statement],
	int         => [RakuAST::IntLiteral],
	str         => [RakuAST::StrLiteral],
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
		RakuAST::Statement::Without,
	],
	iterable => [
		RakuAST::Statement::Loop,
		RakuAST::Statement::For,
		RakuAST::Statement::Whenever,
	],
	ignorable => [
		RakuAST::Block,
		RakuAST::Blockoid,
		RakuAST::StatementList,
		RakuAST::Statement::Expression,
		RakuAST::ArgList,
	],
	node => [
		RakuAST::Node,
	],
	var => [
		RakuAST::VarDeclaration,
		RakuAST::Var,
	],
	var-usage => [
		RakuAST::Var,
	],
	var-declaration => [
		RakuAST::VarDeclaration,
		RakuAST::VarDeclaration::Simple,
	],
);

my %id is Map = (
	"RakuAST::Call"                   => "name",
	"RakuAST::Statement::Expression"  => "expression",
	"RakuAST::Statement::IfWith"      => "condition",
	"RakuAST::Statement::Unless"      => "condition",
	"RakuAST::Literal"                => "value",
	"RakuAST::Name"                   => "simple-identifier",
	"RakuAST::Term::Name"             => "name",
	"RakuAST::ApplyInfix"             => "infix",
	"RakuAST::Infixish"               => "infix",
	"RakuAST::Infix"                  => "operator",
	"RakuAST::Prefix"                 => "operator",
	"RakuAST::Postfix"                => "operator",
	"RakuAST::ApplyInfix"             => "infix",
	"RakuAST::ApplyListInfix"         => "infix",
	"RakuAST::ApplyDottyInfix"        => "infix",
	"RakuAST::ApplyPostfix"           => "postfix",
	"RakuAST::FunctionInfix"          => "function",
	"RakuAST::ArgList"                => "args",
	"RakuAST::Var::Lexical"           => "desigilname",
	"RakuAST::Statement::For"         => "source",
	"RakuAST::Statement::Loop"        => "condition",
	"RakuAST::VarDeclaration"         => "name",
);

method get-id-field($node) {
	for $node.^mro {
		.return with %id{.^name}
	}
}

subset ASTClass of Str will complain {"$_ is not a valid class"} where { !.defined || ::(.Str) !~~ Failure }
subset ASTGroup of Str will complain {"$_ is not a valid group"} where { !.defined || %groups{.Str} }

has ASTClass() @.classes;
has ASTGroup() @.groups;
has @.ids;
has %.atts;
has %.params;
has $.child is rw;
has $.gchild is rw;
has $.parent is rw;
has $.gparent is rw;
has $.descendant is rw;
has $.ascendant is rw;
has Str $.name;
has Callable() @.code;

multi method gist(::?CLASS:D: :$inside = False) {
	"{
		self.^name ~ ".new(" unless $inside
	}{
		(.Str for @!classes).join: ""
	}{
		('.' ~ .Str for @!groups).join: ""
	}{
		('#' ~ .Str for @!ids).join: ""
	}{
		"[" ~ %!atts.kv.map(-> $k, $v { $k ~ ( $v =:= Whatever ?? "" !! "=$v.gist()" ) }).join(', ') ~ ']' if %!atts
	}{
		("\{{$_}}" for @!code).join: ""
	}{
		'$' ~ .Str with $!name
	}{
		" > " ~ .gist(:inside) with $!child
	}{
		" >> " ~ .gist(:inside) with $!gchild
	}{
		" >>> " ~ .gist(:inside) with $!descendant
	}{
		" < " ~ .gist(:inside) with $!parent
	}{
		" << " ~ .gist(:inside) with $!gparent
	}{
		" <<< " ~ .gist(:inside) with $!ascendant
	}{
		")" unless $inside
	}"
}

multi add(ASTQuery::Match $base, $matcher, $node, ASTQuery::Match $match where *.so) {
	$base.list.push: |$match.list;
	for $match.hash.kv -> $key, $value {
		$base.hash.push: $key => $value
	}
	$match
}
multi add($, $, $, $ret) { $ret }

method ACCEPTS($node) {
	say "ACCEPTS: ", self, " -> ", $node.^name if $DEBUG;
	POST $DEBUG ?? say "ACCEPTS: ", self, " -> ", $node.^name, ": ", $_ !! True;
	my $match = ASTQuery::Match.new: :ast($node), :matcher(self);
	{
		my UInt $count = 0;
		my $ans = [
			True,
			{:attr<child>,      :validator<validate-child>     },
			{:attr<descendant>, :validator<validate-descendant>},
			{:attr<gchild>,     :validator<validate-gchild>    },
			{:attr<parent>,     :validator<validate-parent>    },
			{:attr<ascendant>,  :validator<validate-ascendant> },
			{:attr<classes>,    :validator<validate-class>     },
			{:attr<groups>,     :validator<validate-groups>    },
			{:attr<ids>,        :validator<validate-ids>       },
			{:attr<atts>,       :validator<validate-atts>      },
			{:attr<code>,       :validator<validate-code>      },
		].reduce: sub (Bool() $ans, % (Str :$attr, Str :$validator)) {
			return False unless $ans;
			return True  unless self."$attr"();
			++$count;
			my $validated = self."$validator"($node, self."$attr"());
			$match.&add: self, $node, $validated;
		}
		return False unless $ans;
		#$match.hash.push: $!name => $node if $!name;
		say $node.^name, " - ", $match.list if $DEBUG;
	}
	$match
}

multi method validate-code($node, @code) {
	say ::?CLASS.^name, " : validate-code(@)" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-code(@) ===> ", $_ !! True;
	([&&] do for @code -> &code {
		self.validate-code: $node, &code;
	}) ?? ASTQuery::Match.new: :list[$node] !! False
}

multi method validate-code($node, &code) {
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-code(\$) ===> ", $_ !! True;
	code($node) ?? ASTQuery::Match.new: :list[$node] !! False
}

method validate-ascendant($, $parent) {
	say ::?CLASS.^name, " : validate-ascendant" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-ascendant ===> ", $_ !! True;
	ASTQuery::Match.merge: |do for @*LINEAGE -> $ascendant {
		ASTQuery::Match.new(:ast($ascendant), :matcher($parent))
			.query-root-only;
	}
}

method validate-gparent($, $parent) {
	my @ignorables = %groups<ignorable><>;
	say ::?CLASS.^name, " : validate-gparent" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-gparent ===> ", $_ !! True;
	ASTQuery::Match.merge: |do for @*LINEAGE -> $ascendant {
		ASTQuery::Match.new(:ast($ascendant), :matcher($parent))
			.query-root-only || $ascendant ~~ @ignorables.any || last
	}
}

method validate-parent($, $parent) {
	say ::?CLASS.^name, " : validate-parent" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-parent ===> ", $_ !! True;
	ASTQuery::Match.new(:ast(@*LINEAGE.head), :matcher($parent))
		.query-root-only;
}

method validate-descendant($node, $child) {
	say ::?CLASS.^name, " : validate-descendant" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-descendant ===> ", $_ !! True;
	ASTQuery::Match.new(:ast($node), :matcher($child))
		.query-descendants-only;
}

method validate-gchild($node, $gchild) {
	say ::?CLASS.^name, " : validate-gchild" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-gchild ===> ", $_ !! True;
	my $gchild-result = self.validate-child($node, $gchild);
	return $gchild-result if $gchild-result;

	my @list = self.query-child($node, ::?CLASS.new: :groups<ignorable>).list;
	ASTQuery::Match.merge: |do for @list -> $node {
		self.validate-gchild: $node, $gchild
	}
}

method query-child($node, $child, *%pars) {
	say ::?CLASS.^name, " : query-child" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : query-child ===> ", $_ !! True;
	ASTQuery::Match.new(:ast($node), :matcher($child))
		.query-children-only;
}

method validate-child($node, $child) {
	say ::?CLASS.^name, " : validate-child" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-child ===> ", $_ !! True;
	self.query-child($node, $child)
}

multi method validate-groups($node, @groups) {
	say ::?CLASS.^name, " : validate-groups ($node.^name())" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-groups ===> ", $_ !! True;
	self.validate-class: $node, |%groups{@groups}.flat 
}

multi method validate-class($node, @classes) {
	say ::?CLASS.^name, " : validate-class ($node.^name())" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-class ===> ", $_ !! True;
	self.validate-class: $node, |@classes.map: { ::($_) }
}

multi method validate-class($node, **@classes) {
	say ::?CLASS.^name, " : validate-class ($node.^name())" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-class ===> ", $_ !! True;
	[False, |@classes].reduce(-> $ans, $class {
		$ans || $node ~~ $class
	}) ?? ASTQuery::Match.new: :list[$node] !! False
}

method validate-ids($node, @ids) {
	my $key = self.get-id-field: $node;
	return False unless $key;
	[||] do for @ids -> $id {
		self.validate-atts: $node, %($key => $id)
	}
}
method validate-atts($node, %atts) {
	say ::?CLASS.^name, " : validate-atts: %atts.gist()" if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-atts ===> ", $_ !! True;
	[True, |%atts.pairs].reduce(-> $ans, (:$key, :$value is copy) {
		return False unless $ans;
		$value = $value.($node) if $value ~~ Callable;
		my $match = self.validate-value: $node, $key, $value;
		if $ans	&& $ans ~~ ASTQuery::Match {
			for $ans.hash.kv -> $key, $value {
				$match.hash.push: $key => $value
			}
		}
		$match
	})
}

method validate-value($node, $key, $value) {
	say ::?CLASS.^name, " : validate-value: ", $node if $DEBUG;
	POST $DEBUG ?? say ::?CLASS.^name, " : validate-value ===> ", $_ !! True;
	do if $node.^name.starts-with("RakuAST") && $value !~~ ::?CLASS {
		return False unless $key;
		return False unless $node.^can: $key;
		my $nnode = $node."$key"();
		self.validate-value: $nnode, $.get-id-field($nnode), $value
	} else { 
		$value.ACCEPTS: $node;
	}
}
