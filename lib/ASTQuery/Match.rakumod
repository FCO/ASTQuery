use experimental :rakuast;
unit class ASTQuery::Match does Positional does Associative;

has @.list is Array handles <AT-POS push Bool>;
has %.hash is Hash  handles <AT-KEY>;
has $.matcher;
has $.ast;
has Bool $.recursive;

method merge(*@matches) {
	my $new = ::?CLASS.new;
	for @matches -> (:@list, :%hash, |) {
		$new.list.append: @list;
		for %hash.kv -> $key, $value {
			$new.hash.push: $key => $value
		}
	}
	$new
}

method of {RakuAST::Node}

method gist {
	self.raku
}

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
