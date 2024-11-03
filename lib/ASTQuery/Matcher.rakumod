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

multi method add-ast-group(Str $name, ASTClass() @classes) {
	self.add-ast-group: $name, @=@classes.map: { ::($_) }
}

multi method add-ast-group(Str $name, @classes) {
	%groups := {%groups, $name => @classes}.Map
}

multi method set-ast-id(ASTClass:D $class, Str $id where {::($class).^can($_) || fail "$class has no method $id"}) {
	%id := { %id, $class => $id }.Map
}

multi method set-ast-id(Mu:U $class, Str $id) {
	self.set-ast-id: $class.^name, $id
}

multi method add-to-ast-group(ASTGroup $name, *@classes) {
	my @new-classes = @classes.duckmap: -> ASTClass:D $class { ::($class) };
	@new-classes.unshift: |%groups{$name};
	say @new-classes;
	self.add-ast-group: $name, @new-classes
}

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

my $indent = 0;

sub prepare-type($value) {
	my $name = $value.^name;
	$name.subst: /(\w)\w+'::'/, {"$0::"}, :g
}

multi prepare-bool(Bool() $result where *.so) {
	"\o33[32;1mTrue\o33[m"
}

multi prepare-bool(Bool() $result where	*.not) {
	"\o33[31;1mFalse\o33[m"
}

multi prepare-bool(Mu) {"???"}

sub prepare-node($node) {
	"\o33[33;1m{ $node.&prepare-type }\o33[m"
}

my @current-caller;
sub prepare-caller(Bool() :$result) {
	"{
		!$result.defined
			?? "\o33[1m"
			!! $result
				?? "\o33[32;1m"
				!! "\o33[31;1m"
	}{
		do if callframe(4).code.name -> $name {
			@current-caller.push: $name;
			"{$name}({callframe(6).code.signature.params.grep(!*.named).skip>>.gist.join: ", "})"
		} else {
			@current-caller.pop
		}
	}\o33[m"
}

sub prepare-indent($indent, :$end) {
	"\o33[1;30m{
		$indent == 0
			?? ""
			!! join "", "│  " x $indent - 1, $end ?? "└─ " !! "├─ "
	}\o33[m"
}

multi prepare-code(RakuAST::Node $node) {
	"\o33[1m{
		my $txt = $node
			.DEPARSE
			.trans(["\n", "\t"] => ["␤", "␉"])
			.subst(/\s+/, " ", :g)
		;

		$txt.chars > 22
			?? $txt.substr(0, 22) ~ "\o33[30;1m...\o33[m"
			!! $txt
	}\o33[m"
}

multi prepare-code($node) {
	"\o33[31;1m(NOT RakuAST)\o33[m \o33[1m{
		$node
			.trans(["\n", "\t"] => ["␤", "␉"])
	}\o33[m"
}

sub print-validator-begin($node, $value) {
	return unless $DEBUG;
	note $indent.&prepare-indent, $node.&prepare-code, " (", $node.&prepare-node, ") - ", prepare-caller, ": ", $value;
	$indent++;
}

multi print-validator-end($, Mu, Mu $result) {
	True
}

multi print-validator-end($node, $value, $result) {
	return True unless $DEBUG;
	note $indent.&prepare-indent(:end), prepare-caller(:result($result)), " ({ $result.&prepare-bool })";
	$indent--;
	True
}

method ACCEPTS($node) {
	print-validator-begin $node, self.gist;
	POST print-validator-end $node, self.gist, $_;
	my $match = ASTQuery::Match.new: :ast($node), :matcher(self);
	{
		my UInt $count = 0;
		my $ans = [
			True,
			{:attr<classes>,    :validator<validate-class>     },
			{:attr<groups>,     :validator<validate-groups>    },
			{:attr<ids>,        :validator<validate-ids>       },
			{:attr<atts>,       :validator<validate-atts>      },
			{:attr<code>,       :validator<validate-code>      },
			{:attr<child>,      :validator<validate-child>     },
			{:attr<descendant>, :validator<validate-descendant>},
			{:attr<gchild>,     :validator<validate-gchild>    },
			{:attr<parent>,     :validator<validate-parent>    },
			{:attr<ascendant>,  :validator<validate-ascendant> },
		].reduce: sub (Bool() $ans, % (Str :$attr, Str :$validator)) {
			return False unless $ans;
			return True  unless self."$attr"();
			++$count;
			my $validated = self."$validator"($node, self."$attr"());
			$match.&add: self, $node, $validated;
		}
		return False unless $ans;
		#$match.hash.push: $!name => $node if $!name;
		#say $node.^name, " - ", $match.list if $DEBUG;
	}
	$match
}

multi method validate-code($node, @code) {
	print-validator-begin $node, @code;
	POST print-validator-end $node, @code, $_;
	([&&] do for @code -> &code {
		self.validate-code: $node, &code;
	}) ?? ASTQuery::Match.new: :list[$node] !! False
}

multi method validate-code($node, &code) {
	print-validator-begin $node, &code;
	POST print-validator-end $node, &code, $_;
	code($node) ?? ASTQuery::Match.new: :list[$node] !! False
}

method validate-ascendant($node, $parent) {
	print-validator-begin $node, $parent;
	POST print-validator-end $node, $parent, $_;
	ASTQuery::Match.merge-or: |do for @*LINEAGE -> $ascendant {
		ASTQuery::Match.new(:ast($ascendant), :matcher($parent))
			.query-root-only;
	}
}

method validate-gparent($node, $parent) {
	print-validator-begin $node, $parent;
	POST print-validator-end $node, $parent, $_;
	my @ignorables = %groups<ignorable><>;
	ASTQuery::Match.merge-or: |do for @*LINEAGE -> $ascendant {
		ASTQuery::Match.new(:ast($ascendant), :matcher($parent))
			.query-root-only || $ascendant ~~ @ignorables.any || last
	}
}

method validate-parent($node, $parent) {
	print-validator-begin $node, $parent;
	POST print-validator-end $node, $parent, $_;
	ASTQuery::Match.new(:ast(@*LINEAGE.head), :matcher($parent))
		.query-root-only;
}

method validate-descendant($node, $child) {
	print-validator-begin $node, $child;
	POST print-validator-end $node, $child, $_;
	ASTQuery::Match.new(:ast($node), :matcher($child))
		.query-descendants-only;
}

method validate-gchild($node, $gchild) {
	print-validator-begin $node, $gchild;
	POST print-validator-end $node, $gchild, $_;
	my $gchild-result = self.validate-child($node, $gchild);
	return $gchild-result if $gchild-result;

	my @list = self.query-child($node, ::?CLASS.new: :groups<ignorable>).list;
	ASTQuery::Match.merge-or: |do for @list -> $node {
		self.validate-gchild: $node, $gchild
	}
}

method query-child($node, $child, *%pars) {
	print-validator-begin $node, $child;
	POST print-validator-end $node, $child, $_;
	ASTQuery::Match.new(:ast($node), :matcher($child))
		.query-children-only;
}

method validate-child($node, $child) {
	print-validator-begin $node, $child;
	POST print-validator-end $node, $child, $_;
	self.query-child($node, $child)
}

method validate-groups($node, @groups) {
	print-validator-begin $node, @groups;
	POST print-validator-end $node, @groups, $_;
	self.validate-class: $node, %groups{@groups}.flat 
}

multi method validate-class($node, Str $class) {
	print-validator-begin $node, $class;
	POST print-validator-end $node, $class, $_;
	self.validate-class: $node, ::($class)
}

multi method validate-class($node, Mu:U $class) {
	print-validator-begin $node, $class;
	POST print-validator-end $node, $class, $_;
	do if $node ~~ $class {
		ASTQuery::Match.new: :list[$node]
	} else {
		False
	}
}

multi method validate-class($node, @classes) {
	@classes = |@classes.flat;
	print-validator-begin $node, @classes;
	POST print-validator-end $node, @classes, $_;
	#my %done := :{};
	ASTQuery::Match.merge-or: flat @classes.deepmap: -> $class {
		#next if %done{$class}++;
		self.validate-class: $node, $class
	}
}

method validate-ids($node, @ids) {
	print-validator-begin $node, @ids;
	POST print-validator-end $node, @ids, $_;
	my $key = self.get-id-field: $node;
	return False unless $key;
	[||] do for @ids -> $id {
		self.validate-atts: $node, %($key => $id)
	}
}
method validate-atts($node, %atts) {
	print-validator-begin $node, %atts;
	POST print-validator-end $node, %atts, $_;
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
	print-validator-begin $node, $value;
	POST print-validator-end $node, $value, $_;
	do if $node.^name.starts-with("RakuAST") && $value !~~ ::?CLASS {
		return False unless $key;
		return False unless $node.^can: $key;
		my $nnode = $node."$key"();
		self.validate-value: $nnode, $.get-id-field($nnode), $value
	} else { 
		$value.ACCEPTS: $node;
	}
}
