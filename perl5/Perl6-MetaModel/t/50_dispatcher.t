#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 21;
use Data::Dumper;

use Perl6::MetaModel;
    
class Foo => {};   
class Bar => {
    is => [ 'Foo' ]
};
class Baz => {};
class FooBar => {
    is => [ 'Foo', 'Bar' ]
};
class FooBarBaz => {
    is => [ 'FooBar', 'Baz' ]
};
    
{    
    my $d = FooBarBaz->meta->dispatcher();
    my @control = qw(
        FooBarBaz
            FooBar
                Foo
                    Perl6::Object
                Bar
                    Foo
                        Perl6::Object
            Baz
                Perl6::Object    
    );

    my $metaclass = $d->();
    while (defined $metaclass) {
        is($metaclass->name, shift(@control), '... got the metaclass we expected');
        $metaclass = $d->();  
    }
}

class Shape => {};
class Polygon => {
    is => [ 'Shape' ]
};
class Rectangle => {
    is => [ 'Polygon' ]
};
class Square => {
    is => [ 'Rectangle' ]
};

{    
    my $d = Square->meta->dispatcher();
    my @control = qw(
        Square
            Rectangle
                Polygon
                    Shape
                        Perl6::Object
    );

    my $metaclass = $d->();
    while (defined $metaclass) {
        is($metaclass->name, shift(@control), '... got the metaclass we expected');
        $metaclass = $d->();  
    }
}

class Diamond_A => {};
class Diamond_B => {
    is => [ 'Diamond_A' ]
};
class Diamond_C => {
    is => [ 'Diamond_A' ]
};
class Diamond_D => {
    is => [ 'Diamond_B', 'Diamond_C' ]
};

{    
    my $d = Diamond_D->meta->dispatcher();
    my @control = qw(
        Diamond_D
            Diamond_B
                Diamond_A
                    Perl6::Object
            Diamond_C
                Diamond_A
                    Perl6::Object                    
    );

    my $metaclass = $d->();
    while (defined $metaclass) {
        is($metaclass->name, shift(@control), '... got the metaclass we expected');
        $metaclass = $d->();  
    }
}


