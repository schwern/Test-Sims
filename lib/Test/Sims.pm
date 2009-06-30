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

B<THIS IS AN EARLY RELEASE>! While very well tested behaviors may
change.  The interface is not stable.

This is a module to help building semi-random data for testing and to
create large, nested, interesting data structures.

This module contains no new assertions, but it does tie in with
Test::Builder.

It does two things.  It contains functions which make generating
random data easier and it allows you to write repeatable, yet random,
test data.

=head2 make_rand()

    my $code = make_rand $name => \@list;

Creates a subroutine called C<<rand_$name>> and exports it on request.

Also adds it to a "rand" export tag.

=head2 export_sims()

    export_sims();

A utility function which causes your module to export all the
functions called C<<sims_*>>.  It also creates an export tag called
"sims".

=head2 Controlling randomness

You can control the random seed used by Test::Sims by setting the
C<TEST_SIMS_SEED> environment variable.  This is handy to make test runs
repeatable.

Test::Sims will output the seed used at the end of each test run.  If
the test failed it will be visible to the user, otherwise it will be a
TAP comment and only visible if the test is run verbosely.

=cut

use base qw(Exporter);
our @EXPORT = qw(make_rand export_sims);

# Yes, its not a great seed but it doesn't have to be secure.
my $Seed = defined $ENV{TEST_SIMS_SEED} ? $ENV{TEST_SIMS_SEED} : time ^ $$;

# XXX If something else calls srand() we're in trouble
srand($Seed);

## no critic (Subroutines::RequireArgUnpacking)
sub import {
    my $class  = shift;
    my $caller = caller;

    {
        no strict 'refs';
        unshift @{ $caller . "::ISA" }, "Exporter" unless $caller->isa("Exporter");
    }

    return __PACKAGE__->export_to_level( 1, $class, @_ );
}

sub make_rand {
    my $name  = shift;
    my $items = shift;

    my $caller = caller;

    my $code = sub {
        my %args = @_;
        $args{min} = 1 unless defined $args{min};
        $args{max} = 1 unless defined $args{max};

        my $max = int rand( $args{max} - $args{min} + 1 ) + $args{min};

        my @return;
        for( 1 .. $max ) {
            push @return, $items->[ rand @$items ];
        }

        return @return;
    };

    my $func = "rand_$name";
    _alias( $caller, $func, $code );
    _add_to_export_ok( $caller, $func );
    _add_to_export_tags( $caller, $func, 'rand' );

    return $code;
}

sub export_sims {
    my $caller = caller;

    my $symbols = do {
        no strict 'refs';
        \%{ $caller . '::' };
    };

    my @sim_funcs = grep { *{ $symbols->{$_} }{CODE} }
      grep /^sim_/, keys %$symbols;
    for my $func (@sim_funcs) {
        _add_to_export( $caller, $func );
        _add_to_export_tags( $caller, $func, 'sims' );
    }

    return;
}

sub _add_to_export_ok {
    my( $package, $func ) = @_;

    no strict 'refs';
    push @{ $package . '::EXPORT_OK' }, $func;

    return;
}

sub _add_to_export {
    my( $package, $func ) = @_;

    no strict 'refs';
    push @{ $package . '::EXPORT' }, $func;

    return;
}

sub _add_to_export_tags {
    my( $package, $func, $tag ) = @_;

    no strict 'refs';
    my $export_tags = \%{ $package . '::EXPORT_TAGS' };
    push @{ $export_tags->{$tag} }, $func;

    return;
}

sub _alias {
    my( $package, $func, $code ) = @_;

    no strict 'refs';
    *{ $package . '::' . $func } = $code;

    return;
}

sub _display_seed {
    my $tb = shift;

    my $ok = $tb->summary && !( grep !$_, $tb->summary );
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

=head1 SEE ALSO

"Generating Test Data with The Sims"
L<http://schwern.org/talks/Generating%20Test%20Data%20With%20The%20Sims.pdf>
is a set of slides outlining the Sims testing technique which this
module is supporting.


=head1 SOURCE

The source code repository can be found at
L<http://github.com/schwern/Test-Sims>.

The latest release can be found at
L<http://search.cpan.org/dist/Test-Sims>.


=head1 BUGS

Please report bugs, problems, rough corners, feedback and suggestions
to L<http://github.com/schwern/Test-Sims/issues>.

Report early, report often.


=head1 LICENSE and COPYRIGHT

Copyright 2009 Michael G Schwern E<gt>schwern@pobox.comE<lt>

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

=cut

