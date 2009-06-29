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

    my $code = make_rand $name => \@list;

Creates a subroutine called C<<rand_$name>> and exports it on request.


=head2 Controlling randomness

You can control the random seed used by Test::Sims by setting the
C<TEST_SIMS_SEED> environment variable.  This is handy to make test runs
repeatable.

Test::Sims will output the seed used at the end of each test run.  If
the test failed it will be visible to the user, otherwise it will be a
TAP comment and only visible if the test is run verbosely.

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
        my $func = "rand_$name";
        *{$caller .'::'. $func} = $code;
        push @{$caller . '::EXPORT_OK'}, $func;

        my $export_tags = \%{ $caller . '::EXPORT_TAGS' };
        push @{$export_tags->{"rand"}}, $func;
    }

    return $code;
}


sub _display_seed {
    my $tb = shift;

    my $ok = $tb->summary && !(grep !$_, $tb->summary);
    my $msg = "TEST_SIMS_SEED=$Seed";
    $ok ? $tb->note($msg) : $tb->diag($msg);

    return;
}


END {
    require Test::Builder;
    my $tb = Test::Builder->new;

    if( defined $tb->has_plan ) {
        _display_seed($tb);
    }
}

1;
