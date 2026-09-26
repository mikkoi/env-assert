# *.git-repo-admin*

Automate the maintenance of [Git hooks](http://git-scm.com/docs/githooks),
both local and central (bare) repository.
The hooks are executed under [Git::Hooks](https://metacpan.org/release/Git-Hooks) framework.

## Background

Git hooks generally have two main purposes:

1. Automatically trigger external actions, e.g. build or deployment.
2. Trigger code quality checks during certain actions, such as committing or merging.

The code quality checks are often administered only at the point of merging a pull request.
This is frustating to a developer because it means that he learns of the quality errors
only after creating a pull request.

*.git-repo-admin* aims at solving this problem.
All the Git hook configuration is saved together with the repository so that
all of it is available to the developers together with the actual repository.

With the minimum effort, developer can install the equivalent hooks to his local system.
These will perform the same actions during *pre-commit* or *prepare-commit-msg* hooks,
      or other desired hooks.

*.git-repo-admin* also provides an easy way to install hooks in the central (bare) repository
and to keep these hooks updated to use the latest code available or the *master* or *main* branch.


## What Does *.git-repo-admin* Do?

It tries to fulfill several demands:

* Simplify the adoption, maintenance and execution of Git hooks.
* Automate the updating of hooks in a system with multiple users.
* Handle updates with minimum action required from user (but entirely at user's discretion).
* Minimize effect to user's local system (or the server hosting the repos).
  * This is especially important since Git::Hooks framework is created in Perl,
    and the required libraries must be held separate from user's *system Perl*.

## How Does it Do it?

* A simple initialization: one script for user to run. Should be run immediately after *git clone*.
* Automatic updates on the server side: The hook checks at every  at every `git push`
  to master/main branch at every *git push* to master/main branchif there are
  updates to the configuration and reruns the installation script.

## Requirements

* The requirements match Git::Hooks requirements:
    * Git 2.25.1 or later.
    * Perl 5.30 or later.

# Usage

1. Copy the directory *.git-repo-admin* to the root of your repository.
1. Place your Git::Hooks configuration to file *.git-repo-admin/config*.
1. Place your additional hooks (other programs, not Git::Hooks hooks) to the directory
   *.git-repo-admin/hooks.d/<hook_name>*, e.g. pre-commit, commit-msg, etc.
1. If your hooks need additional software installed:
   * Place all Perl module requirements into files *.git-repo-admin/cpanfile.client* or *.git-repo-admin/cpanfile.server*
       together with their exact required versions (or 0 for any version).
   * Put other necessary installation scripts in files
   `.git-repo-admin/install-aux-client.sh` and `.git-repo-admin/install-aux-server.sh`.
1. Commit the whole directory *.git-repo-admin* to your repository.

### Usage: Client Side

* .git-repo-admin client installation checks first

* Execute script *.git-repo-admin/install-client-hooks.sh*.

    .git-repo-admin/install-client-hooks.sh --install

* To remove the hooks, run the following. This only disconnects the hooks and returns the old ones, if any.
  It does not delete the Git::Hooks libraries and dependencies installed locally in `.git/.git-repo-admin/local`.

    .git-repo-admin/install-client-hooks.sh --uninstall

N.B. This install script let's you start your work with a new repository quickly and easily.
If you have *.git-repo-admin* in many local repositories, you should install
the required Perl libraries *Git::Hooks* and *Git::MoreHooks* into your
_System Perl_ (or any other Perl installation in use in the repo).
Otherwise you will need to install them locally to every repo.

* If you are using the hook *Git::MoreHooks::GitRepoAdmin*, you will get a notice
during `git pull` if the hooks configuration has been updated and you should reinstall it.
This happens if the main branch has a higher number in `.git-repo-admin/VERSION`.
Just run `.git-repo-admin/install-client-hooks.sh --install`.
*Be sure your current branch is the main branch!*

# Security

* Client side hooks are never updated automatically because this would pose a security risk as
    user can operate on any branch. Will never run any code from the repo. Only user can run.
* When running `.git-repo-admin/install-client-hooks.sh --install` on a branch other than
    the main branch, you will get a warning.

# FAQ

* Can I use this system of hooks without committing the dir to the repo?

    Yes. Just copy the dir to the repo.
    You can add the name to your *.gitignore* file.
    Then install the client side hooks normally. See above.

* My System Perl doesn't have CPAN or otherwise is very limited. What to do?

    Are you using *.git-repo-admin* on the client side?
    With `[plenv](https://github.com/tokuhirom/plenv)`
    you can easily have local Perl installations
    with any libraries you want.

* Something is wrong. How can I debug *.git-repo-admin*?

    On client side you can raise the logging level by setting environment
    variable: `GITHOOKS_LOG_LEVEL=debug`.

# Copyright & Licensing

This software is copyright (c) 2014-2026 by Mikko Koivunalho.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

Please see file LICENSE.
