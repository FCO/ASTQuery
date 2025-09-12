#use Grammar::Tracer;
unit grammar ASTQuery::Grammar;

token TOP { <str-or-list> }

token word { <-[\s#.\[\]=$>,~+]>+ }
token ns { <[\w:-]>+ }
token akey { <-[\s#.\[\]=$>,~+^$*]>+ }

proto token str          { *                        }
multi token str:<number> { \d+ }
multi token str:<double> { '"' ~ '"' $<str>=<-["]>* }
multi token str:<simple> { "'" ~ "'" $<str>=<-[']>* }
multi token str:<regex>  { '/' ~ '/' $<regex>=<-[/]>+ }

proto token list           { *                                  }
multi token list:<descen>  { <node> \s* '>>>' \s* <str-or-list> }
multi token list:<gchild>  { <node> \s* '>>'  \s* <str-or-list> }
multi token list:<child>   { <node> \s* '>'   \s* <str-or-list> }
multi token list:<ascend>  { <node> \s* '<<<' \s* <str-or-list> }
multi token list:<gparent> { <node> \s* '<<'  \s* <str-or-list> }
multi token list:<parent>  { <node> \s* '<'   \s* <str-or-list> }
#multi token list:<many>   { <node> \s* ',' \s* <str-or-list> }
#multi token list:<after>  { <node> '\s+ '+' \s* <str-or-list> }
#multi token list:<before> { <node> \s* '~' \s* <str-or-list> }
multi token list:<simple> { <node>                               }

proto token str-or-list {*}
multi token str-or-list:<str> {<str>}
multi token str-or-list:<list> {<list>}

token node { <node-part>+ }

proto token node-part              { *                                              }
multi token node-part:<node>       { <ns>                                           }
multi token node-part:<class>      { '.' <word>                                     }
multi token node-part:<id>         { '#' <word>                                     }
multi token node-part:<name>       { '$' <word>                                     }
multi token node-part:<*>          { '*'                                            }
multi token node-part:<par-simple> { ':' <word>                                     }
multi token node-part:<par-arg>    { ':' <word> '(' ~ ')' \d+                       }
multi token node-part:<attr>       { '[' ~ ']' [ <node-part-attr>+ %% [\s*","\s*] ] }
multi token node-part:<code>       { <code>                                         }

token code { '{' ~ '}' $<code>=.*? }
proto token node-part-attr {*}
# Attribute relation operators starting from the attribute node
multi token node-part-attr:<arel-descen>    { <akey> '=>>>' \s* <str-or-list> }
multi token node-part-attr:<arel-gchild>    { <akey> '=>>'  \s* <str-or-list> }
multi token node-part-attr:<arel-child>     { <akey> '=>'   \s* <str-or-list> }
# Attribute value (literal or nested matcher)
multi token node-part-attr:<block>      { <akey>  '=' <code> }
multi token node-part-attr:<a-value>    { <akey>  '=' <str-or-list> }
multi token node-part-attr:<a-contains> { $<attr>=<akey> '~=' [ <str> | $<val>=<akey> ] }
multi token node-part-attr:<a-starts>   { $<attr>=<akey> '^=' [ <str> | $<val>=<akey> ] }
multi token node-part-attr:<a-ends>     { $<attr>=<akey> '$=' [ <str> | $<val>=<akey> ] }
multi token node-part-attr:<a-regex>    { $<attr>=<akey> '*=' <str> }
multi token node-part-attr:<exists>     { <akey>                    }
