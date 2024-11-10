use experimental :rakuast;
use ASTQuery::HighLighter;
unit class ASTQuery::Match does Positional does Associative;

has @.list is Array handles <AT-POS push Bool>;
has %.hash is Hash  handles <AT-KEY>;
has $.matcher;
has $.ast;
has Bool $.recursive;

method merge-or(*@matches) {
	my $new = ::?CLASS.new;
	for @matches.grep: ::?CLASS -> (:@list, :%hash, |) {
		$new.list.append: @list;
		for %hash.kv -> $key, $value {
			$new.hash.push: $key => $value
		}
	}
	$new || False
}

method merge-and(*@matches) {
	my $new = ::?CLASS.new;
	for @matches -> $m {
		return False unless $m;
		given $m -> ::?CLASS:D (:@list, :%hash, |) {
			$new.list.append: @list;
			for %hash.kv -> $key, $value {
				$new.hash.push: $key => $value
			}
		}
	}
	$new
}

method of {RakuAST::Node}

multi prepare-code(@nodes) {
	"[\n{
		do for @nodes -> $node {
			$node.&prepare-code
		}.join("\n").indent: 2
	}\n]"
}

multi prepare-code(RakuAST::Node $node) {
	"\o33[1m{
		my $txt = $node
			.DEPARSE(ASTQuery::HighLighter)
			#.trans(["\n", "\t"] => ["␤", "␉"])
			#.subst(/\s+/, " ", :g)
		;

		#$txt.chars > 72
		#	?? $txt.substr(0, 72) ~ "\o33[30;1m...\o33[m"
		#	!! $txt
		
		$txt
	}\o33[m"
}

multi prepare-code($node) {
	"\o33[31;1m(NOT RakuAST($node.^name()))\o33[m \o33[1m{
		$node
			.trans(["\n", "\t"] => ["␤", "␉"])
	}\o33[m"
}


multi method gist(::?CLASS:U:) {
	self.raku
}

multi method gist(::?CLASS:D:) {
	[
		|do for self.list.kv -> $i, $code {
			"$i => { $code.&prepare-code }",
		},
		|do for self.hash.kv -> $key, $code {
			"$key => { $code.&prepare-code }",
		}
	].join: "\n"
}

method Str {self.gist}

sub match($match, $ast, $matcher) {
	if $matcher.ACCEPTS: $ast -> $m {
		if $m ~~ ::?CLASS {
			for $m.hash.kv -> $key, $value {
				$match.hash.push: $key => $value
			}
		}
		$match.list.push: $ast;
		$match.hash.push: $matcher.name => $ast if $matcher.?name;
	}
}

sub prepare-visitor($match, $matcher) {
	my UInt $position = 0;
	sub visitor($node, :$run-children, :$recursive = $*recursive // True, :$ignore-root = False) {
		#say "visitor: $recursive, $ignore-root: ", $matcher, " -> ", $node.^name;
		$position++;
		my @lineage = @*LINEAGE;
		match $match, $node, $matcher unless $ignore-root;
		#say $match.list;
		{
			my @*LINEAGE = $node, |@lineage;
			my $*recursive = $run-children.defined ?? !$run-children !! $recursive;
			$node.visit-children: &?ROUTINE if $run-children || $recursive;
		}
		$match
	}
}

method query                  { prepare-visitor(self, $!matcher).($!ast)                              }
method query-descendants-only { prepare-visitor(self, $!matcher).($!ast, :ignore-root)                }
method query-children-only    { prepare-visitor(self, $!matcher).($!ast, :run-children, :ignore-root) }
method query-root-only        { prepare-visitor(self, $!matcher).($!ast, :!recursive)                 }
