#!perl
### no critic (ControlStructures::ProhibitPostfixControls)
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

    T2->done_testing;
};

subtest_streamed 'Externals #2' => sub {

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

    T2->done_testing;
};

subtest_streamed 'Externals #3' => sub {
    my %env = (
        USER        => 'random_user',
        HOME        => '/home/users/random_user',
        A_DIGIT     => '123456',
        A_STRING    => 'User Name',
        A_BOOLEAN   => 1,
        AN_OPTIONAL => 'Optional variable',
    );
    my %want = (
        options => {
            exact => 1,
        },
        variables => {
            USER        => { regexp => '^[[:word:]]{1,}$',                  required => 1 },
            HOME        => { regexp => '^[/]{1}[a-z0-9/_-]{1,}[a-z0-9]{1}', required => 1 },
            A_DIGIT     => { regexp => '^\d+$',                             required => 1 },
            A_STRING    => { regexp => '^[[:word:]]{1,}$',                  required => 0 },
            A_BOOLEAN   => { regexp => '^[01]{1}$',                         required => 1 },
            AN_OPTIONAL => { regexp => '^Optional \s [[:word:]]{1,}$',      required => 0 },
        },
    );
    my %opts = ( break_at_first_error => 0, );
    my $r    = assert( \%env, \%want, \%opts );

    T2->is( $r->{'success'},                                       0,                                      'assert not success' );
    T2->is( scalar keys %{ $r->{'errors'}->{'variables'} },        1,                                      'no errors' );
    T2->is( $r->{'errors'}->{'variables'}->{'A_STRING'}->{'type'}, ENV_ASSERT_INVALID_CONTENT_IN_VARIABLE, 'var content invalid' );

    # T2->diag( T2->Dumper( $r->{'errors'} ) );

    T2->done_testing;
};

subtest_streamed 'empty env, all vars optional' => sub {
    my %env;
    my %want = (
        options   => {},
        variables => {
            ANYTHING => { regexp => '^.*$',         required => 0 },
            A_DIGIT  => { regexp => '^\d+$',        required => 0 },
            PORT     => { regexp => '^[0-9}]{1,}$', required => 0 },
        },
    );
    my %opts = ( break_at_first_error => 0, );
    my $r    = assert( \%env, \%want, \%opts );

    T2->ok( $r->{'success'}, 'assert success' );
    T2->is( scalar( keys %{ $r->{'errors'} } ), 0, '3 vars, 0 errors' );

    # T2->diag( T2->Dumper( $r->{'errors'} ) ) if ( keys %{ $r->{'errors'} } );

    T2->done_testing;
};

subtest_streamed 'empty env, two vars optional' => sub {
    my %env;
    my %want = (
        options   => { exact => 0, },
        variables => {
            ANYTHING => { regexp => '^.*$',         required => 0 },
            A_DIGIT  => { regexp => '^\d+$',        required => 1 },
            PORT     => { regexp => '^[0-9}]{1,}$', required => 0 },
        },
    );
    my %opts = ( break_at_first_error => 0, );
    my $r    = assert( \%env, \%want, \%opts );

    T2->is( $r->{'success'}, 0, 'assert success' );
    T2->ok( scalar( keys %{ $r->{'errors'} } ), 'errors received' );
    T2->is( $r->{'errors'}->{'variables'}->{'ANYTHING'}->{'type'}, undef,                               'not error for this var' );
    T2->is( $r->{'errors'}->{'variables'}->{'A_DIGIT'}->{'type'},  ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );
    T2->is( $r->{'errors'}->{'variables'}->{'PORT'}->{'type'},     undef,                               'not error for this var' );

    # T2->diag( T2->Dumper( $r->{'errors'} ) ) if ( keys %{ $r->{'errors'} } );

    T2->done_testing;
};

subtest_streamed 'empty env, all vars required' => sub {
    my %env;
    my %want = (
        options   => {},
        variables => {
            ANYTHING => { regexp => '^.*$',         required => 1 },
            A_DIGIT  => { regexp => '^\d+$',        required => 1 },
            PORT     => { regexp => '^[0-9}]{1,}$', required => 1 },
        },
    );
    my %opts = ( break_at_first_error => 0, );
    my $r    = assert( \%env, \%want, \%opts );

    T2->is( $r->{'success'},                                       0,                                   'assert not success' );
    T2->is( $r->{'errors'}->{'variables'}->{'ANYTHING'}->{'type'}, ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );
    T2->is( $r->{'errors'}->{'variables'}->{'A_DIGIT'}->{'type'},  ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );
    T2->is( $r->{'errors'}->{'variables'}->{'PORT'}->{'type'},     ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );

    T2->done_testing;
};

subtest_streamed 'empty env, 2 var optional, 1 required, demand exact' => sub {
    my %env  = ( ANYTHING => q{}, OTHER_THING => q{123}, );    # In Perl %ENV, ANYTHING= becomes empty string.
    my %want = (
        options   => { exact => 1, },
        variables => {
            ANYTHING => { regexp => '^.*$',         required => 0 },
            A_DIGIT  => { regexp => '^\d+$',        required => 1 },
            PORT     => { regexp => '^[0-9}]{1,}$', required => 0 },
        },
    );
    my %opts = ( break_at_first_error => 0, );
    my $r    = assert( \%env, \%want, \%opts );

    T2->is( $r->{'success'}, 0, 'assert not success' );
    T2->ok( scalar( keys %{ $r->{'errors'} } ), 'errors received' );
    T2->is( [ sort keys %{ $r->{'errors'}->{'variables'} } ],         [qw( A_DIGIT OTHER_THING)],          '2 errors received' );
    T2->is( $r->{'errors'}->{'variables'}->{'A_DIGIT'}->{'type'},     ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );
    T2->is( $r->{'errors'}->{'variables'}->{'OTHER_THING'}->{'type'}, ENV_ASSERT_MISSING_FROM_DEFINITION,  'var missing from env' );

    # T2->diag( T2->Dumper( $r->{'errors'} ) ) if ( keys %{ $r->{'errors'} } );

    T2->done_testing;
};

subtest_streamed 'empty env, 2 var optional, 1 required, no demand exact' => sub {
    my %env  = ( ANYTHING => q{}, OTHER_THING => q{123}, );    # In Perl %ENV, ANYTHING= becomes empty string.
    my %want = (
        options   => { exact => 0, },
        variables => {
            ANYTHING => { regexp => '^.*$',         required => 0 },
            A_DIGIT  => { regexp => '^\d+$',        required => 1 },
            PORT     => { regexp => '^[0-9}]{1,}$', required => 0 },
        },
    );
    my %opts = ( break_at_first_error => 0, );
    my $r    = assert( \%env, \%want, \%opts );

    T2->is( $r->{'success'}, 0, 'assert not success' );
    T2->ok( scalar( keys %{ $r->{'errors'} } ), 'errors received' );
    T2->is( [ sort keys %{ $r->{'errors'}->{'variables'} } ],     [qw( A_DIGIT )],                     '2 errors received' );
    T2->is( $r->{'errors'}->{'variables'}->{'A_DIGIT'}->{'type'}, ENV_ASSERT_MISSING_FROM_ENVIRONMENT, 'var missing from env' );

    # T2->diag( T2->Dumper( $r->{'errors'} ) ) if ( keys %{ $r->{'errors'} } );

    T2->done_testing;
};

T2->done_testing;
