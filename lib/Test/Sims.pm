package Test::Sims;

use strict;
use warnings;


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

=cut

use base qw(Exporter);
our @EXPORT = qw(make_rand);

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
