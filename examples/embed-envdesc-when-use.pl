#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use Carp;

use Env::Assert assert => {
    exact => 0,
    envdesc => <<'EOF'
USER=^[[:word:]]+$
EOF
};

say 'My env is all good!' || croak 'Cannot say';
exit 0;
