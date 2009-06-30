#!/usr/bin/perl

# Test that we can control the randomness of the code.

use strict;
use warnings;

use Test::More;

BEGIN {
    # Anything, so long as its the same.
    $ENV{TEST_SIMS_SEED} = 12345;
}

{

    package Flowers;

    use Test::Sims;

    make_rand "flower" => [qw(Rose Daisy Ed Bob)];

    ::is_deeply [ rand_flower() ], ['Bob'];
    ::is_deeply [ rand_flower( max => 5 ) ], [ 'Ed', 'Ed' ];
}

done_testing();
