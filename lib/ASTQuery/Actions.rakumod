use ASTQuery::Matcher;
unit grammar ASTQuery::Actions;

method TOP($/) { make $<str-or-list>.made }

method word($/) { make $/.Str }
method ns($/)   { make $/.Str }

method str:<number>($/) { make $/.Int }
method str:<double>($/) { make $<str>.Str }
method str:<simple>($/) { make $<str>.Str }

method list:<descen>($/)  {
	make my $node = $<node>.made;
	$node.descendant = $<str-or-list>.made
}
method list:<gchild>($/)  {
	make my $node = $<node>.made;
	$node.gchild = $<str-or-list>.made
}
method list:<child>($/)   {
	make my $node = $<node>.made;
	$node.child = $<str-or-list>.made
}
method list:<ascend>($/)   {
	make my $node = $<node>.made;
	$node.ascendant = $<str-or-list>.made
}
method list:<gparent>($/)   {
	make my $node = $<node>.made;
	$node.gparent = $<str-or-list>.made
}
method list:<parent>($/)   {
	make my $node = $<node>.made;
	$node.parent = $<str-or-list>.made
}
#method list:<many>($/)    { <node> ',' <list> }
#method list:<after>($/)   { <node> '+' <list> }
#method list:<before>($/)  { <node> '~' <list> }
method list:<simple>($/)   { make $<node>.made }

method str-or-list:<str>($/)  { make $<str>.made  }
method str-or-list:<list>($/) { make $<list>.made }

method node($/) {
	my %map := @<node-part>>>.made.classify({ .key }, :as{.value});
	%map<ids> := @=.flat with %map<ids>;
	%map<atts> := %(|.map: { |.Map }) with %map<atts>;
	%map<name> = .head with %map<name>;
	%map<code> := @=.flat with %map<code>;
	#dd %map;
	make my $a = ASTQuery::Matcher.new: |%map.Map;
	#dd $a;
}

method node-part:<node>($/)       { make (:classes($<ns>.made))                  }
method node-part:<class>($/)      { make (:groups($<word>.made))                 }
method node-part:<id>($/)         { make (:ids($<word>.made))                    }
method node-part:<name>($/)       { make (:name($<word>.made))                   }
#method node-part:<*>($/)          { '*'                                          }
#method node-part:<par-simple>($/) { ':' <word>                                   }
#method node-part:<par-arg>($/)    { ':' <word> '(' ~ ')' \d+                     }
method node-part:<attr>($/)       { make (:atts(%=|$<node-part-attr>>>.made))    }
method node-part:<code>($/)       { make (:code($<code>.made))                   }

method code($/) { my $code = Q|sub ($_?, :match($/)) { | ~ $<code>.Str ~ Q| }|; make $code.AST.EVAL }

method node-part-attr:<exists>($/)     { make ($<word>.made => True)                }
method node-part-attr:<block>($/)      { make ($<word>.made => $<code>.made)        }
method node-part-attr:<a-value>($/)    { make ($<word>.made => $<str-or-list>.made) }
#method node-part-attr:<a-contains>($/) { '[' ~ ']' [ <word> '~=' [ <str> | <list> ] ] }
#method node-part-attr:<a-starts>($/)   { '[' ~ ']' [ <word> '^=' [ <str> | <list> ] ] }
#method node-part-attr:<a-ends>($/)     { '[' ~ ']' [ <word> '$=' [ <str> | <list> ] ] }
#method node-part-attr:<a-regex>($/)    { '[' ~ ']' [ <word> '*=' [ <str> | <list> ] ] }

