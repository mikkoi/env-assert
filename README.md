# envassert

Ensure that the environment variables match
what is requested, or abort.

# DESCRIPTION

**envassert** checks that your runtime environment, as defined
with environment variables, matches with what you want.

You can define your required environment in a file.
Default file is **.envassert** but you can use any file.
It is advantageous to use **envassert** for examnple when running
a container. If you check your environment for missing or
wrongly defined environment variables at the beginning of
the container run, your container will fail sooner instead
of in a later point in execution when the variables are needed.

# SYNOPSIS

envassert [options]

Options:

    --help
    --man
    --break-at-error
    --env-description

## CLI interface without dependencies

The **envassert** command is also available
as self contained executable.
You can download it and run it as it is without
additional installation of CPAN packages.
Of course, you still need Perl, but Perl comes with any
normal Linux installation.

This can be convenient if you want to, for instance,
include **envassert** in a docker container build.

    curl -LSs -o envassert https://raw.githubusercontent.com/mikkoi/env-assert/master/script/envassert.packed
    chmod +x ./envassert
