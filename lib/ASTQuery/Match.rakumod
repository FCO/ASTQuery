use experimental :rakuast;
use ASTQuery::Matcher;
unit class ASTQuery::Match does Positional does Associative;

has @.list is Array handles <AT-POS push>;
has %.hash is Hash  handles <AT-KEY>;
has $.matcher;
has $.ast;
has Bool $.recursive;

method of {RakuAST::Node}

method gist {
	"ASTQuery::Match => " ~ $!matcher.gist
}

sub match($match, $ast, $matcher) {
	do if $ast ~~ $matcher {
		$match.list.push: $ast;
		$match.hash.push: $matcher.name => $ast if $matcher.?name;
		True
	}
}

sub visitor($node, :$run-children, :$recursive = $*recursive // True, :$ignore-root = False) {
	#say "visitor: $recursive, $ignore-root: ", $*matcher, " -> ", $node.^name;
	$*position++;
	my @lineage = @*LINEAGE;
	match $*match, $node, $*matcher unless $ignore-root;
	#say $*match.list;
	{
		my @*LINEAGE = $node, |@lineage;
		my $*recursive = $run-children.defined ?? !$run-children !! $recursive;
		my $*position = 0;
		$node.visit-children: &?ROUTINE if $run-children || $recursive;
	}
}

method query {
	my $*match = self;
	my $*matcher = $!matcher;
	my $*position = 0;
	visitor $!ast;
	self
}

method query-descendants-only {
	my $*match = self;
	my $*matcher = $!matcher;
	my $*position = 0;
	visitor $!ast, :ignore-root;
	self
}

method query-children-only {
	my $*match = self;
	my $*matcher = $!matcher;
	my $*position = 0;
	visitor $!ast, :run-children, :ignore-root;
	self
}

method query-root-only {
	my $*match = self;
	my $*matcher = $!matcher;
	my $*position = 0;
	visitor $!ast, :!recursive;
	self
}
