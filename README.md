[![License: Artistic-2.0](https://img.shields.io/badge/License-Perl-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)
[![CPAN Version](https://img.shields.io/cpan/v/Env-Assert)](https://metacpan.org/dist/Env-Assert)
[![kwalitee](https://cpants.cpanauthors.org/dist/Env-Assert.svg)](https://cpants.cpanauthors.org/dist/Env-Assert)
[![codecov](https://codecov.io/gh/mikkoi/env-assert/graph/badge.svg?token=WSOLKXXEVK)](https://codecov.io/gh/mikkoi/env-assert)
[![Coverage Status](https://coveralls.io/repos/github/mikkoi/env-assert/badge.svg?branch=add-codecov-report)](https://coveralls.io/github/mikkoi/env-assert?branch=add-codecov-report)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/mikkoi/env-assert)
[![GH Actions: Linux Build](https://github.com/mikkoi/env-assert/actions/workflows/linux.yml/badge.svg?event=push&branch=main)](https://github.com/mikkoi/env-assert/actions/workflows/linux.yml)
[![GH Actions: Windows Build](https://github.com/mikkoi/env-assert/actions/workflows/windows.yml/badge.svg?event=push&branch=main)](https://github.com/mikkoi/env-assert/actions/workflows/windows.yml)

# Env-Assert

Ensure that the environment variables match what is requested, or abort. Module and executable.


# VERSION

0.016


# SYNOPSIS

    use Env::Assert 'assert';
    # or:
    use Env::Assert assert => {
        envdesc_file => 'another-envdesc',
        break_at_first_error => 1,
    };

    # .envdesc file:
    # MY_VAR=.+

    # use any verified environment variable
    say $ENV{MY_VAR};

    # You can inline the envdesc file:
    use Env::Assert assert => {
        exact => 1,
        envdesc => <<'EOF'
    NUMERIC_VAR=^[[:digit:]]+$
    TIME_VAR=^\d{2}:\d{2}:\d{2}$
    EOF
    };


# DESCRIPTION

**envassert** checks that your runtime environment, as defined
with environment variables, matches with what you want.

You can define your required environment in a file.
Default file is `.envassert` but you can use any file.

It is advantageous to use **envassert** for example when running
a container. If you check your environment for missing or
wrongly defined environment variables at the beginning of
the container run, your container will fail sooner instead
of in a later point in execution when the variables are needed.

## Errors

There are three kinds of errors:

- ENV\_ASSERT\_MISSING\_FROM\_ENVIRONMENT

    "Variable &lt;var\_name> is missing from environment"

- ENV\_ASSERT\_INVALID\_CONTENT\_IN\_VARIABLE

    "Variable &lt;var\_name> has invalid content"

- ENV\_ASSERT\_MISSING\_FROM\_DEFINITION

    "Variable &lt;var\_name> is missing from description"

    This error will only be reported if you have set
    the special option **exact**. See below.

## Environment Description Language

Environment is described in file `.envdesc`.
Environment description file is a Unix shell compatible file,
similar to a `.env` file.

### `.envdesc` Format

In `.envdesc` file there is only environment variables, comments
or empty rows.
Example:

    # Required env
    ## envassert (opts: exact=1)
    FILENAME=^[[:word:]]{1,}$

Env var name is followed by a regular expression. The regexp is
an extended Perl regular expression without quotation marks.
One env var and its descriptive regexp use one row.

A comment begins at the beginning of the row and uses the whole row.
It start with '#' character.

Two comment characters and the word **envassert** at the beginning of the row
mean this is an **envassert** meta command.
You can specify different environment related options with these commands.

Supported options:

- exact

    The option _exact_ means that all allowed env variables
    are described in this file. Any unknown env var causes an error
    when verifying.

## CLI interface without dependencies

The `envassert` command is also available
as self contained executable.
You can download it and run it as it is without
additional installation of CPAN packages.
Of course, you still need Perl, but Perl comes with any
normal Linux installation.

This can be convenient if you want to, for instance,
include `envassert` in a docker container build.

    curl -LSs -o envassert https://raw.githubusercontent.com/mikkoi/env-assert/main/envassert.self-contained
    chmod +x ./envassert


## INSTALLATION

### Packaging

[![Packaging status](https://repology.org/badge/vertical-allrepos/env-assert.svg)](https://repology.org/project/env-assert/versions)

### CLI interface without dependencies

The **envassert** command is also available
as self contained executable.
You can download it and run it as it is without
additional installation of CPAN packages.
Of course, you still need Perl, but Perl comes with any
normal Linux installation.

This can be convenient if you want to, for instance,
include **envassert** in a docker container build.

    curl -LSs -o envassert https://raw.githubusercontent.com/mikkoi/env-assert/main/envassert.self-contained
    chmod +x ./envassert


# LICENSE

This software is copyright (c) 2026 by Mikko Koivunalho <mikkoi@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

Terms of the Perl programming language system itself:

a) the GNU General Public License as published by the Free
   Software Foundation; either version 1, or (at your option) any
   later version, or
b) the "Artistic License"

The complete licenses are in the files LICENSE-Artistic-2.0 and LICENSE-GPL-3
within this repository. If these files are missing, they can be downloaded
from the following urls:

    * https://www.gnu.org/licenses/
    * https://www.perlfoundation.org/artistic-license-20.html
