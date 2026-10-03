#!perl
use strict;
use warnings;

use Test2::V1 qw( -utf8 -x -strict -warnings ), -include => ['Data::Dumper'];
use Test2::Tools::Subtest qw( subtest_streamed );

use Env::Assert::Functions qw( assert :constants );

subtest_streamed 'Externals' => sub {

    {
        my %env  = ( USER => 'random_user', );
        my %want = (
            options => {
                exact => 1,
            },
            variables => {},
        );
        my %opts = ();

        my $r = assert( \%env, \%want, \%opts );
        T2->is( $r->{'success'},                                   0,                                  'assert not success' );
        T2->is( scalar keys %{ $r->{'errors'} },                   1,                                  'has errors' );
        T2->is( $r->{'errors'}->{'variables'}->{'USER'}->{'type'}, ENV_ASSERT_MISSING_FROM_DEFINITION, 'var missing from def' );
    }

    {
        my %env  = ( USER => 'random_user', );
        my %want = (
            options => {
                exact => 1,
            },
            variables => {
                USER => { regexp => '^[[:word:]]{1}$', required => 1 },
            },
        );
        my %opts = ();

        my $r = assert( \%env, \%want, \%opts );
        T2->is( $r->{'success'},                 0, 'assert not success' );
        T2->is( scalar keys %{ $r->{'errors'} }, 1, 'has errors' );
        T2->is(
            $r->{'errors'}->{'variables'}->{'USER'}->{'type'},
            ENV_ASSERT_INVALID_CONTENT_IN_VARIABLE,
            'invalid content in var'
        );
    }

    {
        my %env  = ( USER => 'random_user', );
        my %want = (
            options => {
                exact => 1,
            },
            variables => {
                NOUSER => { regexp => '^[[:word:]]{1}$', required => 1 },
            },
        );
        my %opts = ();

        my $r = assert( \%env, \%want, \%opts );
        T2->is( $r->{'success'},                                     0,                                   'assert not success' );
        T2->is( scalar keys %{ $r->{'errors'} },                     1,                                   'has errors' );
        T2->is( $r->{'errors'}->{'variables'}->{'NOUSER'}->{'type'}, ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );
    }

    {
        my %env  = ( USER => 'random_user', );
        my %want = (
            options   => { exact => 0, },
            variables => {
                NOUSER => { regexp => '^[[:word:]]{1}$', required => 1 },
                NOPATH => { regexp => '^[[:word:]]{1}$', required => 1 },
            },
        );
        my %opts = ( break_at_first_error => 0, );

        my $r = assert( \%env, \%want, \%opts );
        T2->is( $r->{'success'},                                     0,                                   'assert not success' );
        T2->is( scalar keys %{ $r->{'errors'}->{'variables'} },      2,                                   'has errors' );
        T2->is( $r->{'errors'}->{'variables'}->{'NOUSER'}->{'type'}, ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );
        T2->is( $r->{'errors'}->{'variables'}->{'NOPATH'}->{'type'}, ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );
    }

    {
        my %env = (
            USER    => 'random_user',
            HOME    => '/home/users/random_user',
            A_DIGIT => '123456',
        );
        my %want = (
            options => {
                exact => 1,
            },
            variables => {
                USER    => { regexp => '^[[:word:]]{1,}$',                  required => 1 },
                HOME    => { regexp => '^[/]{1}[a-z0-9/_-]{1,}[a-z0-9]{1}', required => 1 },
                A_DIGIT => { regexp => '\d+',                               required => 1 },
            },
        );
        my %opts = ( break_at_first_error => 0, );
        my $r    = assert( \%env, \%want, \%opts );

        T2->ok( $r->{'success'}, 'assert success' );
        T2->is( scalar keys %{ $r->{'errors'} }, 0, 'no errors' );
        T2->diag( T2->Dumper( $r->{'errors'} ) );
    }

    T2->done_testing;
};

T2->done_testing;
