use ASTQuery::Matcher;
use MONKEY-SEE-NO-EVAL;
unit grammar ASTQuery::Actions;

method TOP($/) { make $<str-or-list>.made }

method word($/) { make $/.Str }
method ns($/)   { make $/.Str }
method akey($/)  { make $/.Str }

method str:<number>($/) { make $/.Int }
method str:<double>($/) { make $<str>.Str }
method str:<simple>($/) { make $<str>.Str }
method str:<regex>($/)  { make EVAL "rx/" ~ $<regex>.Str ~ "/" }

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
	%map<functions> := @=.flat with %map<functions>;
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
method node-part:<function>($/)   { make (:functions($<word>.made))              }
#method node-part:<*>($/)          { '*'                                          }
#method node-part:<par-simple>($/) { ':' <word>                                   }
#method node-part:<par-arg>($/)    { ':' <word> '(' ~ ')' \d+                     }
method node-part:<attr>($/)       { make (:atts(%=|$<node-part-attr>>>.made))    }
method node-part:<code>($/)       { make (:code($<code>.made))                   }

method code($/) { my $code = Q|sub ($_?, :match($/)) { | ~ $<code>.Str ~ Q| }|; make $code.AST.EVAL }

method node-part-attr:<exists>($/)     { make ($<akey>.made => True)                }
method node-part-attr:<block>($/)      { make ($<akey>.made => $<code>.made)        }
# '=' now accepts only literal strings or numbers via <str>
method node-part-attr:<a-value>($/)    { make ($<akey>.made => $<str-or-list>.made) }

# Attribute relation operators on attribute value
method node-part-attr:<arel-child>($/)  {
	make ($<akey>.made => ASTQuery::Matcher::AttrRel.new(:rel<child>, :matcher($<str-or-list>.made)))
}
method node-part-attr:<arel-gchild>($/) {
	make ($<akey>.made => ASTQuery::Matcher::AttrRel.new(:rel<gchild>, :matcher($<str-or-list>.made)))
}
method node-part-attr:<arel-descen>($/) {
	make ($<akey>.made => ASTQuery::Matcher::AttrRel.new(:rel<descendant>, :matcher($<str-or-list>.made)))
}

method node-part-attr:<a-contains>($/) { make ($<attr>.made => ASTQuery::Matcher::AttrOp.new(:op<contains>, :value(($<str> // $<val>).made))) }
method node-part-attr:<a-starts>($/)   { make ($<attr>.made => ASTQuery::Matcher::AttrOp.new(:op<starts>,   :value(($<str> // $<val>).made))) }
method node-part-attr:<a-ends>($/)     { make ($<attr>.made => ASTQuery::Matcher::AttrOp.new(:op<ends>,     :value(($<str> // $<val>).made))) }
method node-part-attr:<a-regex>($/)    { make ($<attr>.made => ASTQuery::Matcher::AttrOp.new(:op<regex>,    :value($<str>.made))) }



