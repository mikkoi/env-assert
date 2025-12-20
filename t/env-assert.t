#!perl
## no critic [BuiltinFunctions::ProhibitStringyEval]
use strict;
use warnings;

use Cwd qw( getcwd abs_path );
use FindBin qw( $RealBin );
use File::Spec ();
my $lib_path;
BEGIN {
    $lib_path = File::Spec->catdir(($RealBin =~ /(.+)/msx)[0], q{.}, 'lib');
}
use lib "$lib_path";

use Test2::V0;

use Carp qw( croak );
use English qw( -no_match_vars ) ;  # Avoids regex performance
use FileHandle ();
use File::Path qw( make_path );
use File::Temp ();

# use Test2::Require::Platform::Unix;

subtest 'Use Env::Assert plain without import arguments' => sub {
    # Do not use __FILE__ because its value is not absolute and not updated
    # when chdir is done.
    my $this = getcwd;
    ($this) = $this =~ /(.+)/msx; # Make it non-tainted
    my $subdir_path = File::Spec->catdir( $RealBin, 'env-assert' );
    chdir $subdir_path || croak;

    # $new_env{$_} = $ENV{$_} foreach (keys %ENV);
    # delete $new_env{'ENVDOT_FILEPATHS'} if exists $new_env{'ENVDOT_FILEPATHS'};
    # $new_env{ALERT_EMAIL} = 'alert@example.com';
    # $new_env{SITE_URL} = 'https://www.example.com';
    # $new_env{GITHUB_TOKEN} = '0123456789qwertyuiop';

    my %new_env = (
        ALERT_EMAIL  => 'alert@example.com',
        SITE_URL     => 'https://www.example.com',
        GITHUB_TOKEN => '0123456789qwertyuiop',
    );
    # We need to replace the current %ENV, not change individual values.
    local %ENV = %new_env;
    local $EVAL_ERROR = undef;
    my $code = <<'EOF';
use Env::Assert;
1;
EOF
    my $r = eval $code;
    is( $EVAL_ERROR, q{}, 'use Env::Assert okay' );
    is( $r, 1, 'evaled okay');

    chdir $this;

    done_testing;
};

subtest 'Wrong import argument' => sub {
    # Do not use __FILE__ because its value is not absolute and not updated
    # when chdir is done.
    # my $this = getcwd;
    # ($this) = $this =~ /(.+)/msx; # Make it non-tainted
    # my $subdir_path = File::Spec->catdir( $RealBin, 'env-assert' );
    # chdir $subdir_path || croak;

    my %new_env = (
        ALERT_EMAIL  => 'alert@example.com',
        SITE_URL     => 'https://www.example.com',
        GITHUB_TOKEN => '0123456789qwertyuiop',
    );

    # We need to replace the current %ENV, not change individual values.
    local %ENV = %new_env;

    local $EVAL_ERROR = undef;
    my $code = <<'EOF';
use Env::Assert qw(not_assert);
1;
EOF
    my $r = eval $code;
    like($EVAL_ERROR, qr/^Unknown \s argument \s 'not_assert' .*$/msx, 'use Env::Assert failed' );
    is( $r, undef, 'evaled okay');
    # is($EVAL_ERROR, q{}, 'use Env::Dot failed' );

    done_testing;
};

subtest 'Inline env desc file' => sub {
    # Do not use __FILE__ because its value is not absolute and not updated
    # when chdir is done.
    # my $this = getcwd;
    # ($this) = $this =~ /(.+)/msx; # Make it non-tainted
    # my $subdir_path = File::Spec->catdir( $RealBin, 'env-assert' );
    # chdir $subdir_path || croak;

    my %new_env = (
        # ALERT_EMAIL  => 'alert@example.com',
        # SITE_URL     => 'https://www.example.com',
        # GITHUB_TOKEN => '0123456789qwertyuiop',
        NUMVAR       => '12345',
        TEXTVAR      => 'example_text',
    );

    # We need to replace the current %ENV, not change individual values.
    local %ENV = %new_env;

    local $EVAL_ERROR = undef;
    my $code = <<'EOF';
use Env::Assert assert => {
    envdesc => q{
NUMVAR=^\d+$
TEXTVAR=^\w+\$
},
};
1;
EOF
    my $r = eval $code;
    is( $EVAL_ERROR, q{}, 'use Env::Assert okay' );
    is( $r, 1, 'evaled okay');
    # like($EVAL_ERROR, qr/^Unknown \s argument \s 'not_assert' .*$/msx, 'use Env::Assert failed' );
    # is( $r, undef, 'evaled okay');
    # is($EVAL_ERROR, q{}, 'use Env::Dot failed' );

    done_testing;
};

subtest 'Point to another env desc file' => sub {
    my $subdir_filepath = File::Spec->catfile( $RealBin, 'env-assert', 'another-envdesc' );
    my %new_env = (
        # ALERT_EMAIL  => 'alert@example.com',
        # SITE_URL     => 'https://www.example.com',
        # GITHUB_TOKEN => '0123456789qwertyuiop',
        A_NUMVAR       => '12345',
        A_TEXTVAR      => 'example_text',
    );

    # We need to replace the current %ENV, not change individual values.
    local %ENV = %new_env;

    local $EVAL_ERROR = undef;
    my $code = <<"EOF";
use Env::Assert assert => {
    envdesc_file => '$subdir_filepath',
};
1;
EOF
    local $EVAL_ERROR = undef;
    my $r = eval $code;
    is($EVAL_ERROR, q{}, 'use Env::Assert successfull' );
    is( $r, 1, 'evaled okay');

    done_testing;
};

done_testing;
