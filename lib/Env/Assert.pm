## no critic (ControlStructures::ProhibitPostfixControls)
## no critic (ValuesAndExpressions::ProhibitConstantPragma)
package Env::Assert;
use strict;
use warnings;
use 5.010;

# ABSTRACT: Ensure that the environment variables match what you need, or abort.

our $VERSION = '0.015';

# We define our own import routine because
# this is the point (when `use Env::Assert` is called)
# when we do our magic.

use Carp;

use English qw( -no_match_vars ); # Avoids regex performance penalty in perl 5.18 and earlier
use open ':std', IO => ':encoding(UTF-8)';

use Env::Assert::Functions qw( :all );

use constant {
    ENV_DESC_FILENAME => '.envdesc',
};

# Handle exports
{
    no warnings 'redefine';    ## no critic [TestingAndDebugging::ProhibitNoWarnings]

    sub import {
        my ($class, $cmd, $args) = @_;

        # We also allow only: 'use Env::Assert;'
        croak "Unknown argument '$cmd'" if( $cmd && $cmd ne 'assert' );

        if( ! assert_env( %{ $args } ) ) {
            croak 'Errors in environment detected.';
        }
        return;
    }
}

=pod

=for :stopwords env filepath filepaths

=head1 SYNOPSIS

=for test_synopsis BEGIN { die 'SKIP: no .envdesc file here' }

    use Env::Assert 'assert';
    # or:
    use Env::Assert assert => {
        envdesc_file => 'another-envdesc',
        break_at_first_error => 1,
    };

    # .envdesc file:
    # MY_VAR=.+

    # use any environment variable
    say $ENV{MY_VAR};

    # You can inline the envdesc file:
    use Env::Assert assert => {
        exact => 1,
        envdesc => <<'EOF'
    NUMERIC_VAR=^[[:digit:]]+$
    TIME_VAR=^\d{2}:\d{2}:\d{2}$
    };
    EOF

=head1 STATUS

Package Env::Assert is currently being developed so changes in the API are possible,
though not likely.

=head1 NOTES

Functionality of L<Env::Assert> has been moved to module L<Env::Assert::Functions> since version 0.013.
L<Env::Assert> has a different API now.

=head1 METHODS

=head2 assert_env

Read environment description, F<.envdesc> by default,
and compare current environment.

=cut

sub assert_env {
    my (%args) = @_;
    local $OUTPUT_AUTOFLUSH = 1;

    my $break_at_first_error = $args{'break_at_first_error'}//0;
    my $exact = $args{'exact'}//0;

    my @env_desc_rows;
    if( $args{'envdesc'} ) {
        @env_desc_rows = map { "$_\n" } split qr/\n/msx, $args{'envdesc'};
    } else {
        my $env_desc_filename = $args{'envdesc_file'}//ENV_DESC_FILENAME;
        open my $fh, q{<}, $env_desc_filename or croak "Cannot open file '$env_desc_filename'";
        @env_desc_rows = <$fh>;
        close $fh or croak "Cannot close file '$env_desc_filename'";
    }

    my $desc = file_to_desc( @env_desc_rows );
    my %parameters;
    $parameters{'break_at_first_error'} = $break_at_first_error
        if defined $break_at_first_error;
    $desc->{'options'}->{'exact'} = $exact
        if defined $exact;
    my $r = assert( \%ENV, $desc, \%parameters );
    if( ! $r->{'success'} ) {
        print {*STDERR} report_errors( $r->{'errors'} )
            or croak 'Cannot print errors to STDERR';
        return 0;
    }
    return 1;
}

=head1 DEPENDENCIES

No external dependencies outside Perl's standard distribution.

=head1 SEE ALSO

L<Env::Dot> is a "sister" to Env::Assert.
Read environment variables from a F<.env> file directly into you program.
There is also script F<envdot> which can turn F<.env> file's content
into environment variables for different shells.

=cut

1;

__END__
