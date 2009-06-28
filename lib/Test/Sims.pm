package Test::Sims;

use strict;
use warnings;

our $VERSION = "20090628";


=head1 NAME

Test::Sims - Helps build semi-random data for testing

=head1 SYNOPSIS

    package My::Sims;

    use Test::Sims;

    # Creates rand_name() and exported on demand.
    make_rand name => [
        qw(Mal Zoe Jayne Kaylee Inara River Simon Wash Zoe Book)
    ];

    # Automatically exported
    sub sim_character {
        my %defaults = (
            name   => rand_name(),
            series => "Firefly",
        );

        require Character;
        return Character->new(
            %defaults, @_;
        );
    }


=head1 DESCRIPTION

This is a module to help building semi-random data for testing and to
create large, nested, interesting data structures.

This module contains no new assertions, but it does tie in with
Test::Builder.

It does two things.  It contains functions which make generating
random data easier and it allows you to write repeatable, yet random,
test data.

=head2 Automatic exports

By using Test::Sims your module will inherit from Exporter.

=begin todo

It will automatically export any functions called C<<sim_*>> and will
export anything called C<<rand_*>> on demand.  In addition there will
be export tags.  C<<:sim>> will export all C<<sim_*>> functions and
C<<:rand>> all C<<rand_*>> functions.  C<<:ALL>> exports everything.

=end todo

=head2 make_rand()

=head2 TEST_SIMS_SEED

=cut

use base qw(Exporter);
our @EXPORT = qw(make_rand);

# Yes, its not a great seed but it doesn't have to be secure.
my $Seed = defined $ENV{TEST_SIMS_SEED} ? $ENV{TEST_SIMS_SEED} : time ^ $$;

# XXX If something else calls srand() we're in trouble
srand($Seed);

sub import {
    my $class = shift;
    my $caller = caller;

    {
        no strict 'refs';
        unshift @{$caller. "::ISA"}, "Exporter" unless $caller->isa("Exporter");
    }

    __PACKAGE__->export_to_level(1, $class, @_);
}

sub make_rand {
    my $name = shift;
    my $items = shift;

    my $caller = caller;

    my $code = sub {
        my %args = @_;
        $args{min} = 1 unless defined $args{min};
        $args{max} = 1 unless defined $args{max};

        my $max = int rand($args{max} - $args{min} + 1) + $args{min};

        my @return;
        for (1..$max) {
            push @return, $items->[rand @$items];
        }

        return @return;
    };

    {
        no strict 'refs';
        *{$caller . '::rand_' . $name} = $code;
        push @{$caller . '::EXPORT_OK'}, "rand_$name";
    }

    return $code;
}


1;
