#use Grammar::Tracer;
unit grammar ASTQuery::Grammar; token TOP { <list> }

token word { <-[\s#.\[\]=]>+ }
token ns { <[\w:-]>+ }

proto token str          { *                        }
multi token str:<number> { \d+ }
multi token str:<double> { '"' ~ '"' $<str>=<-["]>* }
multi token str:<simple> { "'" ~ "'" $<str>=<-[']>* }

proto token list          { *                 }
multi token list:<simple> { <node>            }
multi token list:<many>   { <node> ',' <list> }
multi token list:<descen> { <node> \s+ <list> }
multi token list:<child>  { <node> '>' <list> }
multi token list:<after>  { <node> '+' <list> }
multi token list:<before> { <node> '~' <list> }

proto token str-or-list {*}
multi token str-or-list:<str> {<str>}
multi token str-or-list:<list> {<list>}

token node { <node-part>+ }

proto token node-part              { *                              }
multi token node-part:<node>       { <ns>                           }
multi token node-part:<class>      { '.' <word>                     }
multi token node-part:<id>         { '#' <word>                     }
multi token node-part:<*>          { '*'                            }
multi token node-part:<par-simple> { ':' <word>                     }
multi token node-part:<par-arg>    { ':' <word> '(' ~ ')' \d+       }
multi token node-part:<attr>       { '[' ~ ']' [ <node-part-attr> ] }

proto token node-part-attr {*}
multi token node-part-attr:<a-value>    { <word>  '=' <str-or-list> }
multi token node-part-attr:<a-contains> { <word> '~=' <str-or-list> }
multi token node-part-attr:<a-starts>   { <word> '^=' <str-or-list> }
multi token node-part-attr:<a-ends>     { <word> '$=' <str-or-list> }
multi token node-part-attr:<a-regex>    { <word> '*=' <str-or-list> }
multi token node-part-attr:<exists>     { <word>                    }
