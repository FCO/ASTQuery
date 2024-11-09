#!/usr/bin/env raku
use paths;

sub AST_QUERY__get-query {
   use ::("ASTQuery");
   return ::("ASTQuery::EXPORT::ALL::&ast-query")
}

sub AST_QUERY__run-query($query, $file) {
	CATCH {
		default {
			return "\o33[31;1m ERROR: { .message }\o33[m"
		}
	}
	my &query := AST_QUERY__get-query;
	$file.slurp.AST.&query: $query
}

sub MAIN(Str $query, $dir?) {
	my &query := &AST_QUERY__run-query.assuming: $query;
	my @files = paths(:file(*.ends-with(any <raku rakumod rakutest rakuconfig p6 pl6 pm6>)), |($_ with $dir));
	for @files -> IO() $file {
		my $match = try $file.&query;
		with $match {
			say "{ $file.relative}:";
			say .gist.indent: 2
		}
	}
}
