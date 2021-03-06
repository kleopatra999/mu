# Regular QOTW #8
# http://perl.plover.com/qotw/r/solution/008

use v6;

my $SEG_LENGTH = 4;

my %wordmap;
for lines() -> $word is copy {
    next if $word ~~ /\W/;
    my $w = $word.lc;
    my %w = map -> $i { substr($w,$i,$SEG_LENGTH)=>1 },
                   0..$word.chars-$SEG_LENGTH;

    for keys %w -> $w { 
        %wordmap{$w} = %wordmap.exists($w) ?? undef !! $word; 
    }
}

my $q = open("questions",:w) or die;
my $a = open("answers",:w) or die;
for (sort keys %wordmap) {
    next unless defined %wordmap{$_};
    say $q: $_;
    say $a: %wordmap{$_};
}
$q.close; $a.close;
