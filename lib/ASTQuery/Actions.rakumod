use ASTQuery::Matcher;
unit grammar ASTQuery::Actions;

method TOP($/) { make $<list>.made }

method word($/) { make $/.Str }
method ns($/)   { make $/.Str }

method str:<number>($/) { make $/.Int }
method str:<double>($/) { make $<str>.Str }
method str:<simple>($/) { make $<str>.Str }

method list:<child>($/)   { make my $node = $<node>.made; $node.child = $<str-or-list>.made }
#method list:<many>($/)   { <node> ',' <list> }
#method list:<descen>($/) { <node> \s+ <list> }
#method list:<after>($/)  { <node> '+' <list> }
#method list:<before>($/) { <node> '~' <list> }
method list:<simple>($/)  { make $<node>.made }

method str-or-list:<str>($/)  { make $<str>.made  }
method str-or-list:<list>($/) { make $<list>.made }

method node($/) {
	my %map := @<node-part>>>.made.Map;
	make my $a = ASTQuery::Matcher.new: |%map;
	#dd $a;
}

method node-part:<node>($/)       { make (:class($<ns>.made))                    }
method node-part:<class>($/)      { make (:group($<word>.made))                  }
method node-part:<id>($/)         { make (:id($<word>.made))                     }
method node-part:<name>($/)       { make (:name($<word>.made))                     }
#method node-part:<*>($/)          { '*'                                          }
#method node-part:<par-simple>($/) { ':' <word>                                   }
#method node-part:<par-arg>($/)    { ':' <word> '(' ~ ')' \d+                     }
method node-part:<attr>($/)       { make (:atts(%=$<node-part-attr>.made))      }

method node-part-attr:<exists>($/)     { make ($<word>.made => Whatever)     }
method node-part-attr:<a-value>($/)    { make ($<word>.made => $<str-or-list>.made) }
#method node-part-attr:<a-contains>($/) { '[' ~ ']' [ <word> '~=' [ <str> | <list> ] ] }
#method node-part-attr:<a-starts>($/)   { '[' ~ ']' [ <word> '^=' [ <str> | <list> ] ] }
#method node-part-attr:<a-ends>($/)     { '[' ~ ']' [ <word> '$=' [ <str> | <list> ] ] }
#method node-part-attr:<a-regex>($/)    { '[' ~ ']' [ <word> '*=' [ <str> | <list> ] ] }

