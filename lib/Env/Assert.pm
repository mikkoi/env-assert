## no critic [ControlStructures::ProhibitPostfixControls]
## no critic [ValuesAndExpressions::ProhibitConstantPragma]
## no critic (ControlStructures::ProhibitCascadingIfElse)
package Env::Assert;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(
    assert
    report_errors
    file_to_desc
    );
our %EXPORT_TAGS = (
    'all'          => [qw( assert report_errors file_to_desc )],
);

use English qw( -no_match_vars ); # Avoids regex performance penalty in perl 5.18 and earlier
use Carp;

# ABSTRACT: Ensure that the environment variables match what you need, or abort.

our $VERSION = '0.010';

use constant  {
    ENV_ASSERT_MISSING_FROM_ENVIRONMENT => 1,
    ENV_ASSERT_INVALID_CONTENT_IN_VARIABLE => 2,
    ENV_ASSERT_MISSING_FROM_DEFINITION => 3,
    DEFAULT_PARAMETER_BREAK_AT_FIRST_ERROR => 0,
    INDENT => q{    },
};

=pod

=for stopwords params env

=head1 STATUS

Package Env::Assert is currently being developed so changes in the API are possible,
though not likely.


=head1 SYNOPSIS

    use Env::Assert qw( assert report_errors );

    my %want = (
        options => {
            exact => 1,
        },
        variables => {
            USER => { regexp => '^[[:word:]]{1}$', required => 1 },
        },
    );
    my %parameters;
    $parameters{'break_at_first_error'} = 1;
    my $r = assert( \%ENV, \%want, \%parameters );
    if( ! $r->{'success'} ) {
        print report_errors( $r->{'errors'} );
    }


=head1 NOTES

=cut


=head1 DEPENDENCIES

No external dependencies outside Perl's standard distribution.


=head1 FUNCTIONS

No functions are automatically exported to the calling namespace.

=head2 assert( \%env, \%want, \%params )

Ensure your environment, parameter I<env> (hashref), matches with
the environment description, parameter I<want> (hashref).
Use parameter I<params> (hashref) to specify processing options.

Supported params:

=over 8

=item break_at_first_error

Verify environment only up until the first error.
Then break and return with only that error.

=back

Return: hashref: { success => 1/0, errors => hashref, };


=cut

sub assert {
    my ($env, $want, $params) = @_;
    $params = {} if ! $params;
    croak 'Invalid options. Not a hash' if( ref $env ne 'HASH' || ref $want ne 'HASH' );

    # Set default options
    $params->{'break_at_first_error'} //= DEFAULT_PARAMETER_BREAK_AT_FIRST_ERROR;

    my $success = 1;
    my %errors;
    my $vars = $want->{'variables'};
    my $opts = $want->{'options'};
    foreach my $var_name (keys %{ $vars }) {
        my $var = $vars->{$var_name};
        my $required = $var->{'required'}//1;
        my $regexp = $var->{'regexp'}//q{.*};
        if( ( $opts->{'exact'} || $required ) && ! defined $env->{$var_name} ) {
            $success = 0;
            $errors{'variables'}->{ $var_name } = {
                type => ENV_ASSERT_MISSING_FROM_ENVIRONMENT,
                message => "Variable $var_name is missing from environment",
            };
            goto EXIT if( $params->{'break_at_first_error'} );
        }
        elsif( $env->{$var_name} !~ m/$regexp/msx ) {
            $success = 0;
            $errors{'variables'}->{ $var_name } = {
                type => ENV_ASSERT_INVALID_CONTENT_IN_VARIABLE,
                message => "Variable $var_name has invalid content",
            };
            goto EXIT if( $params->{'break_at_first_error'} );
        }
    }
    if( $opts->{'exact'} ) {
        foreach my $var_name (keys %{ $env }) {
            if( ! exists $vars->{ $var_name } ) {
                $success = 0;
                $errors{'variables'}->{ $var_name } = {
                    type => ENV_ASSERT_MISSING_FROM_DEFINITION,
                    message => "Variable $var_name is missing from description",
                };
                goto EXIT if( $params->{'break_at_first_error'} );
            }
        }
    }

    EXIT:
    return { success => $success, errors => \%errors, };
}

=head2 report_errors( \%errors )

Report errors in a nicely formatted way.

=cut

sub report_errors {
    my ($errors) = @_;
    my $out = q{};
    $out .= sprintf "Environment Assert: ERRORS:\n";
    foreach my $error_area_name (sort keys %{ $errors }) {
        $out .= sprintf "%s%s:\n", INDENT, $error_area_name;
        foreach my $error_key (sort keys %{ $errors->{$error_area_name} }) {
            $out .= sprintf "%s%s: %s\n", INDENT . INDENT, $error_key,
                $errors->{$error_area_name}->{$error_key}->{'message'};
        }
    }
    return $out;
}

=head2 file_to_desc( @rows )

Extract an environment description from a F<.envdesc> file.

=cut

sub file_to_desc {
    my @rows = @_;
    my %desc = ( 'options' => {}, 'variables' => {}, );
    foreach (@rows) {
        # This is envassert meta command
        ## no critic (RegularExpressions::ProhibitComplexRegexes)
        if(
            m{
            ^ [[:space:]]{0,} [#]{2}
            [[:space:]]{1,} envassert [[:space:]]{1,}
            [(] opts: [[:space:]]{0,} (?<opts> .*) [)]
            [[:space:]]{0,} $
            }msx
        ) {
            my $opts = _interpret_opts( $LAST_PAREN_MATCH{opts} );
            foreach ( keys %{ $opts } ) {
                $desc{'options'}->{$_} = $opts->{$_};
            }
        } elsif(
            # This is comment row
            m{
                ^ [[:space:]]{0,} [#]{1} .* $
            }msx
        ) {
            1;
        } elsif(
            # This is empty row
            m{
                ^ [[:space:]]{0,} $
            }msx
        ) {
            1;
        } elsif(
            # This is env var description
            m{
                ^ (?<name> [^=]{1,}) = (?<value> .*) $
            }msx
        ) {
            $desc{'variables'}->{ $LAST_PAREN_MATCH{name} } = {
                regexp => $LAST_PAREN_MATCH{value}
            };
        }
    }
    return \%desc;
}

# Private subroutines

sub _interpret_opts {
    my ($opts_str) = @_;
    my @opts = split qr{
        [[:space:]]{0,} [,] [[:space:]]{0,}
        }msx,
    $opts_str;
    my %opts;
    foreach (@opts) {
        my ($key, $val) = split qr/=/msx;
        $opts{$key} = $val;
    }
    return \%opts;
}

1;
