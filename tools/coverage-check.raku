#!/usr/bin/env raku
use MONKEY-TYPING;

sub parse-percent(Str $s) { $s.subst(/^'percent='/, '').trim.Num }

sub MAIN(Str :$baseline-file = '.coverage-baseline') {
	my $out = qqx/raku -I. tools\/coverage.raku/;
	my $line = $out.lines.grep(*.starts-with('percent=')).head // '';
	my $current = parse-percent($line) // 0e0;

	my $prev = Nil;
	if $baseline-file.IO.e { $prev = $baseline-file.IO.slurp.trim.Num }

	if $prev.defined {
		if $current < $prev {
			note "Coverage decreased: was {$prev}%, now {$current}% (-{sprintf('%.2f', $prev - $current)}).";
		} elsif $current > $prev {
			note "Coverage increased: was {$prev}%, now {$current}% (+{sprintf('%.2f', $current - $prev)}).";
		} else {
			note "Coverage unchanged at {$current}%.";
		}
	} else {
		note "Initializing coverage baseline at {$current}%.";
	}

	spurt $baseline-file, sprintf('%.2f', $current) ~ "\n";
	say "percent={$current}"; # machine-friendly echo
}
