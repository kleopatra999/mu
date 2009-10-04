use v6;

use Test;

plan 23;

=begin desc

Tests C<CATCH> blocks.

=end desc



# L<S04/"Exception handlers"/If you define a CATCH block within the try, it replaces the default CATCH>

dies_ok { die 'blah'; CATCH {} }, 'Empty CATCH rethrows exception';
dies_ok { try {die 'blah'; CATCH {}} }, 'CATCH in try overrides default exception handling';



# L<S04/"Exception handlers"/any block can function as a try block if you put a CATCH block within it>

lives_ok { die 'blah'; CATCH {default {}} }, 'Closure with CATCH {default {}} ignores exceptions';
lives_ok { do {die 'blah'; CATCH {default {}}}; }, 'do block with CATCH {default {}} ignores exceptions';

{
    my $f = sub { die 'blah'; CATCH {default {}} };
    lives_ok $f, 'Subroutine with CATCH {default {}} ignores exceptions';

    $f = sub ($x) {
        if $x {
            die 'blah';
            CATCH { default {} }
        }
        else {
            die 'blah';
        }
    };
    lives_ok { $f(1) }, 'if block with CATCH {default {}} ignores exceptions...';
    dies_ok { $f(0) }, "...but the CATCH doesn't affect exceptions thrown in an attached else";
}



#L<S04/"Exception handlers"/An exception handler is just a switch statement>

#unless eval 'Exception.new' {
#    skip_rest "No Exception objects"; exit;
#}

{
    # exception classes
    class Naughty is Exception {};

    my ($not_died, $caught);
    {
        die Naughty("error");

        $not_died = 1;

        CATCH {
            when Naughty {
                $caught = 1;
            }
        }
    };

    ok(!$not_died, "did not live after death");
    #?pugs 1 todo
    #?rakudo todo 'smart matching against exception'
    ok($caught, "caught exception of class Naughty");
};

{
    # exception superclass
    class Naughty::Specific is Naughty {};
    class Naughty::Other is Naughty {};

    my ($other, $naughty);
    {
        die Naughty::Specific("error");

        CATCH {
            when Naughty::Other {
                $other = 1;
            }
            when Naughty {
                $naughty = 1;
            }
        }
    };

    ok(!$other, "did not catch sibling error class");
    #?pugs 1 todo
    #?rakudo todo 'smart matching against exception'
    ok($naughty, "caught superclass");
};

{
    # uncaught class
    class Dandy is Exception {};

    my ($naughty, $lived);
    eval '
        {
            die Dandy("error");

            CATCH {
                when Naughty {
                    $naughty = 1;
                }
            }
        };
        $lived = 1;
    ';

    #?rakudo todo 'CATCH'
    ok(!$lived, "did not live past uncaught throw");
    ok(!$naughty, "did not get caught by wrong handler");
    ok(~WHAT($!), '$! is an object');
    #?pugs skip 'bug'
    #?rakudo todo 'Exception types'
    is(WHAT($!), Dandy, ".. of the right class");
};

{
    my $s = '';
    die 3;
    CATCH {
        when 1 {$s ~= 'a';}
        when 2 {$s ~= 'b';}
        when 3 {$s ~= 'c';}
        when 4 {$s ~= 'd';}
        default {$s ~= 'z';}
    }

    is $s, 'c', 'Caught number';
};

{
    my $catches = 0;
    sub rt63430 {
        {
            return 63430;
            CATCH { return 73313 if ! $catches++; }
        }
    }

    #?rakudo skip 'Null PMC access'
    is rt63430().perl, 63430.perl, 'can call rt63430() and examine the result';
    #?rakudo skip 'Null PMC access in type()'
    is rt63430(), 63430, 'CATCH does not intercept return from bare block';
    #?rakudo skip 'invalid since other calls were skipped (noauto)'
    is $catches, 0, 'CATCH block never invoked';
};



# L<S04/"Exception handlers"/a CATCH block never attempts to handle any exception thrown within its own dynamic scope>

#?rakudo 4 todo 'CATCH block catching its own exceptions (RT #64262)'
{
    my $catches = 0;
    try {
        {
            die 'catch!';
            CATCH { default {die 'caught' if ! $catches++;} }
        };
    }

    is $catches, 1, "CATCH doesn't catch exceptions thrown in its own lexical scope";

    $catches = 0;
    my $f = { die 'caught' if ! $catches++; };
    try {
        {
            die 'catch!';
            CATCH { default {$f()} }
        };
    }

    is $catches, 1, "CATCH doesn't catch exceptions thrown in its own dynamic scope";

    my $s = '';
    {
        die 'alpha';
        CATCH {
            default {
                $s ~= 'a';
                die 'beta';
            }
            CATCH {
                default { $s ~= 'b'; }
            }
        }
    };

    is $s, 'ab', 'CATCH directly nested in CATCH catches exceptions thrown in the outer CATCH';

    $s = '';
    {
        die 'alpha';
        CATCH {
            default {
                $s ~= 'a';
                die 'beta';
                CATCH {
                    default { $s ~= 'b'; }
                }
            }
        }
    };

    is $s, 'ab', 'CATCH indirectly nested in CATCH catches exceptions thrown in the outer CATCH';
};



# vim: ft=perl6