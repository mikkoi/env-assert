#!/usr/bin/env perl
use strict;
use warnings;
use 5.030;                               # Git::Hooks requirement
use English qw( -no_match_vars );
use FindBin 1.51 qw( $RealBin );         ## no critic (Community::DiscouragedModules)
use File::Spec;

my ( $log_level, $log_file );

BEGIN {
    my $log_path = File::Spec->catdir( ( $RealBin =~ /(.+)/msx )[0], 'githooks.log' );
    $log_level = $ENV{GITHOOKS_LOG_LEVEL} // 'warning';
    $log_file  = $ENV{GITHOOKS_LOG_FILE}  // $log_path;
}

# Git::Hooks uses Log::Any so we set it up.
use Log::Any qw( $log );
use Log::Any::Adapter;
Log::Any::Adapter->set( 'File', $log_file, log_level => $log_level );
use Git::Hooks;

# PROGRAM_NAME, the name of the hook file with path that was called
$PROGRAM_NAME =~ m/ (?: .*) [\/]{1} (?<hook_name> .+) $ /msx;
$log->debug( "PROGRAM_NAME: '$PROGRAM_NAME'; hook_name: '" . $LAST_PAREN_MATCH{hook_name} . q{'} );
run_hook( $LAST_PAREN_MATCH{hook_name}, @ARGV );
