unit grammar ASTQuery::Grammar;

token TOP { <list> }

token word { \w+ }
token ns { <[\w:]> }

proto token str          { *                 }
multi token str:<double> { '"' ~ '"' <-["]>* }
multi token str:<simple> { "'" ~ "'" <-[']>* }

proto token list          { *                 }
multi token list:<simple> { <node>            }
multi token list:<many>   { <node> ',' <list> }
multi token list:<descen> { <node> \s+ <list> }
multi token list:<child>  { <node> '>' <list> }
multi token list:<after>  { <node> '+' <list> }
multi token list:<before> { <node> '~' <list> }

token node { <node-part>+ }

proto token node-part              { *                                            }
multi token node-part:<node>       { <ns>                                         }
multi token node-part:<class>      { '.' <word>                                   }
multi token node-part:<id>         { '#' <word>                                   }
multi token node-part:<*>          { '*'                                          }
multi token node-part:<attr>       { '[' ~ ']' <word>                             }
multi token node-part:<a-value>    { '[' ~ ']' [ <word>  '=' [ <str> | <list> ] ] }
multi token node-part:<a-contains> { '[' ~ ']' [ <word> '~=' [ <str> | <list> ] ] }
multi token node-part:<a-starts>   { '[' ~ ']' [ <word> '^=' [ <str> | <list> ] ] }
multi token node-part:<a-ends>     { '[' ~ ']' [ <word> '$=' [ <str> | <list> ] ] }
multi token node-part:<a-regex>    { '[' ~ ']' [ <word> '*=' [ <str> | <list> ] ] }
multi token node-part:<par-simple> { ':' <word>                                   }
multi token node-part:<par-arg>    { ':' <word> '(' ~ ')' \d+                     }
