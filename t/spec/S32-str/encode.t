use v6;
use Test;
plan 7;


# L<S32::Containers/Buf>

ok 'ab'.encode('ASCII') ~~ Buf, '$str.encode returns a Buf';
ok ('ab'.encode('ASCII') eqv Buf.new(97, 98)),  'encoding to ASCII';
ok ('ö'.encode('UTF-8') eqv Buf.new(195, 182)), 'encoding to UTF-8';

# verified with Perl 5:
# perl -CS -Mutf8 -MUnicode::Normalize -e 'print NFD("ä")' | hexdump -C
ok ('ä'.encode('UTF-8', 'D') eqv Buf.new(:16<61>, :16<cc>, :16<88>)),
                'encoding to UTF-8, with NFD';

ok Buf.new(195, 182).decode ~~ Str, '.decode returns a Str';
is Buf.new(195, 182).decode, 'ö', 'decoding a Buf with UTF-8';
is Buf.new(246).decode('ISO-8859-1'), 'ö', 'decoding a Buf with Latin-1';

# vim: ft=perl6