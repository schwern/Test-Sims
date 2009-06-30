#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More;

plan skip_all => "DateTime needed" unless eval { require DateTime };

{
    package Sim::Date;

    use strict;
    use warnings;

    require DateTime;
    use Test::Sims;

    make_rand year  => [1800..2100];
    make_rand month => [1..12];
    make_rand day   => [1..31];
    make_rand hour  => [0..23];
    make_rand minute=> [0..59];
    make_rand second=> [0..59];

    sub sim_datetime {
        my %defaults = (
            year   => rand_year(),
            month  => rand_month(),
            day    => rand_day(),
            hour   => rand_hour(),
            minute => rand_minute(),
            second => rand_second(),
        );

        return DateTime->new(
            %defaults, @_
        );
    }

    export_sims();
}


{
    package Foo;

    use Test::More;
    Sim::Date->import();

    my $date = sim_datetime();

    cmp_ok $date->year, ">=", 1800;
    cmp_ok $date->year, "<=", 2101;

    $date = sim_datetime(
        year   => 2008,
        second => 23,
    );

    is $date->year, 2008;
    is $date->second, 23;
}


done_testing();
