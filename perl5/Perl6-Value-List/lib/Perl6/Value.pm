#
# Value classes - Num, Int, Str, Bit, Pair
#
# Perl6::Value::Num
# Perl6::Value::Int
# Perl6::Value::Str
# Perl6::Value::Bit
# - functions for implementation of Perl6 Values in Perl5

# ChangeLog
#
# 2005-08-15
# * added boxed types: Num, Int, Str, Bit, Pair
#
# 2005-08-13
# * refactored from Perl6::Value::List

# TODO - Ref

use strict;

use Perl6::MetaModel;
use Perl6::Object;

my $class_description = '-0.0.1-cpan:FGLOCK';

class 'Num'.$class_description => {
    is => [ 'Perl6::Object' ],
    class => {
        attrs => [],
        methods => {
            # TODO - pi ?
            'Inf' => sub {
                my ($class) = @_;           
                return $class->new( '$.value' => &Perl6::Value::Num::Inf );
            },
            'NaN' => sub {
                my ($class) = @_;           
                return $class->new( '$.value' => &Perl6::Value::Num::NaN );
            },
        }
    },
    instance => {
        attrs => [ '$.value' ],
        DESTROY => sub {},
        methods => {
            'num' => sub { SELF },
            'int' => sub { Int->new( '$.value' => Perl6::Value::Num::to_int( _('$.value') ) ) },
            'str' => sub { Str->new( '$.value' => Perl6::Value::Num::to_str( _('$.value') ) ) },
            'bit' => sub { Bit->new( '$.value' => Perl6::Value::Num::to_bit( _('$.value') ) ) },
        },
    }
};

class 'Int'.$class_description => {
    is => [ 'Perl6::Object' ],
    class => {
        attrs => [],
        methods => {}
    },
    instance => {
        attrs => [ '$.value' ],
        DESTROY => sub {},
        methods => {
            'num' => sub { Num->new( '$.value' => Perl6::Value::Int::to_num( _('$.value') ) ) },
            'int' => sub { SELF },
            'str' => sub { Str->new( '$.value' => Perl6::Value::Int::to_str( _('$.value') ) ) },
            'bit' => sub { Bit->new( '$.value' => Perl6::Value::Int::to_bit( _('$.value') ) ) },
        },
    }
};

class 'Str'.$class_description => {
    is => [ 'Perl6::Object' ],
    class => {
        attrs => [],
        methods => {}
    },
    instance => {
        attrs => [ '$.value' ],
        DESTROY => sub {},
        methods => {
            'num' => sub { Num->new( '$.value' => Perl6::Value::Str::to_num( _('$.value') ) ) },
            'int' => sub { Int->new( '$.value' => Perl6::Value::Str::to_int( _('$.value') ) ) },
            'str' => sub { SELF },
            'bit' => sub { Bit->new( '$.value' => Perl6::Value::Str::to_bit( _('$.value') ) ) },
        },
    }
};

class 'Bit'.$class_description => {
    is => [ 'Perl6::Object' ],
    class => {
        attrs => [],
        methods => {}
    },
    instance => {
        attrs => [ '$.value' ],
        DESTROY => sub {},
        methods => {
            'num' => sub { Num->new( '$.value' => Perl6::Value::Bit::to_num( _('$.value') ) ) },
            'int' => sub { Int->new( '$.value' => Perl6::Value::Bit::to_int( _('$.value') ) ) },
            'str' => sub { Str->new( '$.value' => Perl6::Value::Bit::to_str( _('$.value') ) ) },
            'bit' => sub { SELF },
        },
    }
};

class 'Pair'.$class_description => {
    is => [ 'Perl6::Object' ],
    class => {
        attrs => [],
        methods => {}
    },
    instance => {
        attrs => [ '$.key', [ '$.value' => { access => 'rw' } ] ],
        DESTROY => sub {},
        methods => {
            'num' => sub { Num->new( '$.value' => 0 ) },
            'int' => sub { Int->new( '$.value' => 0 ) },
            'str' => sub { Str->new( '$.value' => '' ) },
            'bit' => sub { Bit->new( '$.value' => 0 ) },
        },
    }
};

package Perl6::Value::Num;

use constant Inf => 100**100**100;
use constant NaN => Inf / Inf;

sub to_str        { 
    my $v = 0 + $_[0];
    return 'Inf'  if $v == Inf;
    return '-Inf' if $v == -&Inf;
    return 'NaN'  if $v =~ m/n/i;
    return "" . $v 
}
sub to_bit        { $_[0] == 0 ? 0 : 1 }
sub to_num        { 0 + $_[0] }
sub to_int        { int( $_[0] ) }

package Perl6::Value::Int;

sub to_str        { 
    my $v = 0 + $_[0];
    return 'Inf'  if $v == Perl6::Value::Num::Inf;
    return '-Inf' if $v == -&Perl6::Value::Num::Inf;
    return 'NaN'  if $v =~ m/n/i;
    return "" . $v 
}
sub to_bit        { $_[0] != 0 }
sub to_num        { 0 + $_[0] }
sub to_int        { $_[0] }

package Perl6::Value::Str;

sub to_str        { $_[0] }
sub to_bit        { 
    return 0 if $_[0] eq '0' || $_[0] eq '';
    return 1;
}
sub to_num        {
    my $v = $_[0];
    $v =~ s/\s+//g;
    return Perl6::Value::Num::Inf  if $v eq 'Inf';
    return -&Perl6::Value::Num::Inf if $v eq '-Inf';
    return Perl6::Value::Num::NaN  if $v eq 'NaN';
    return 0 + $v;
}
sub to_int        { Perl6::Value::Num::to_int( to_num( $_[0] ) ) }

package Perl6::Value::Bit;

sub to_str        { $_[0] == 0 ? 'bool::false' : 'bool::true' }
sub to_bit        { $_[0] }
sub to_num        { $_[0] == 0 ? 0 : 1 }
sub to_int        { to_num( $_[0] ) }

1;
__END__

=head1 NAME

Perl6::Value - functions for implementation of Perl6 Values in Perl5

=head1 SYNOPSIS

  use Perl6::Value;
  
  # unboxed Perl5 value
  my $num = Perl6::Value::Str::to_num( 'NaN' );
 
  # Perl6 "Num" object
  my $num = Num->NaN;

=head1 DESCRIPTION

This module implements the "Value" classes - Num, Int, Str, Bit, Pair.

It also implements platform-specific, low-level functions for "unboxed" Values.

=head1 SEE ALSO

Pugs

=head1 AUTHOR

Flavio S. Glock, E<lt>fglock@Egmail.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Flavio S. Glock

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
