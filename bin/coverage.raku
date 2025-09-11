#!/usr/bin/env raku
# Wrapper around racoco to print total coverage percent in machine-friendly form
# Requires: zef install --/test App::RaCoCo

sub MAIN(*@args) {
    my $out = qqx/racoco -I/;
    say $out if $*ENV<ASTQUERY_DEBUG>;
    my $percent = $out.lines.grep(*.starts-with('Coverage:')).map({ .subst('Coverage: ', '').subst('%', '').trim }).head;
    say "percent={$percent // '0'}";
}
