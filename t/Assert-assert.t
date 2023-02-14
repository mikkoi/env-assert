#!perl
## no critic [ValuesAndExpressions::ProhibitConstantPragma]
use strict;
use warnings;
use Test2::V0;

use Env::Assert qw( :all );

use constant  {
    ENV_ASSERT_MISSING_FROM_ENVIRONMENT => 1,
    ENV_ASSERT_INVALID_CONTENT_IN_VARIABLE => 2,
    ENV_ASSERT_MISSING_FROM_DEFINITION => 3,
};
subtest 'Internals' => sub {

    #
    my %env = (
        USER => 'random_user',
    );
    my %want = (
        options => {
            exact => 1,
        },
        variables => {
        },
    );
    my %opts = (
    );

    my $r = assert( \%env, \%want, \%opts );
    is( $r->{'success'}, 0, 'assert not success' );
    is( %{ $r->{'errors'} }, 1, 'has errors' );
    is( $r->{'errors'}->{'variables'}->{'USER'}->{'type'},
        ENV_ASSERT_MISSING_FROM_DEFINITION, 'var missing from def' );

    #
    %want = (
        options => {
            exact => 1,
        },
        variables => {
            USER => { regexp => '^[[:word:]]{1}$', required => 1 },
        },
    );

    $r = assert( \%env, \%want, \%opts );
    is( $r->{'success'}, 0, 'assert not success' );
    is( %{ $r->{'errors'} }, 1, 'has errors' );
    is( $r->{'errors'}->{'variables'}->{'USER'}->{'type'},
        ENV_ASSERT_INVALID_CONTENT_IN_VARIABLE, 'invalid content in var' );

    #
    %want = (
        options => {
            exact => 1,
        },
        variables => {
            NOUSER => { regexp => '^[[:word:]]{1}$', required => 1 },
        },
    );

    $r = assert( \%env, \%want, \%opts );
    is( $r->{'success'}, 0, 'assert not success' );
    is( %{ $r->{'errors'} }, 1, 'has errors' );
    is( $r->{'errors'}->{'variables'}->{'NOUSER'}->{'type'},
        ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );




    #
    %env = (
        USER => 'random_user',
        HOME => '/home/users/random_user',
        A_DIGIT => '123456',
    );
    %want = (
        options => {
            exact => 1,
        },
        variables => {
            USER => { regexp => '^[[:word:]]{1,}$', required => 1 },
            HOME => { regexp => '^[/]{1}[a-z0-9/_-]{1,}[a-z0-9]{1}', required => 1 },
            A_DIGIT => { regexp => '\d+', required => 1 },
        },
    );
    %opts = (
        break_at_first_error => 0,
    );
    $r = assert( \%env, \%want, \%opts );

    ok( $r->{'success'}, 'assert success' );
    is( $r->{'success'}, 1, 'assert not success' );
    is( %{ $r->{'errors'} }, 0, 'no errors' );

    done_testing;
};

done_testing;
