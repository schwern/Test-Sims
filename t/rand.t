#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my $tb = Test::More->builder;
my @names = qw(Mal Zoe Jayne Kaylee Inara River Simon Wash Zoe Book);
my %names = map { $_ => 1 } @names;
sub rand_ok {
    my $min  = shift;
    my $max  = shift;
    my $have = shift;
    my $name = shift;

    my $ok = 1;

    my $count = @$have;
    $ok &&= ($min <= $count && $count <= $max);
    $tb->ok( $ok, "Wrong number of items: $name" );
    $tb->diag(<<DIAG) unless $ok;
Wrong number of items.
have: $count
want: $min .. $max
DIAG

    my %diff;
    for my $item (@$have) {
        $diff{$item}++ unless $names{$item};
    }

    if( keys %diff ) {
        $ok &&= $tb->ok( 0, $name );
        $tb->diag("Differing item: $_") for keys %diff;
    }
    else {
        $ok &&= $tb->ok( 1, $name );
    }

    return $ok;
}

{
    package Sim::Firefly;

    use Test::Sims;

    make_rand name => \@names;
}

{
    package Foo;

    Sim::Firefly->import("rand_name");

    ::rand_ok 1, 1, [rand_name()], "no args";
    ::rand_ok 2, 5, [rand_name( min => 2, max => 5 )], "min/max";
    ::rand_ok 1, 5, [rand_name( max => 5 )],           "just max";
    ::rand_ok 0, 2, [rand_name( min => 0, max => 2 )], "min 0/max";
}

done_testing();
