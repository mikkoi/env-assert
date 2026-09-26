#!/usr/bin/env bash

function install_hook {
    git_dir="$1"
    admin_dir="$2"
    hook="$3"
    hook_path="${git_dir}/hooks/${hook}"
    hook_d_dir="${git_dir}/hooks.d/${hook}"
    \mkdir -p "${hook_d_dir}"
    hook_target="${admin_dir}/githooks.pl"

    if ! \test -a "${hook_path}"; then
        # If hook not exists, just write one
        echo "Create ${hook_path}"
        \ln --symbolic "${hook_target}" "${hook_path}"
    else
        if [[ $(\file "${hook_path}") == "${hook_path}: symbolic link to ${hook_target}" ]]; then
            echo "Hook ${hook} exists. Skipping..."
        else
            hook_d_path="${hook_d_dir}/${hook}"
            echo "Moving previous ${hook} hook file to ${hook_d_path}"
            \mkdir -p "${hook_d_dir}"
            \mv "${hook_path}" "${hook_d_path}"
            \ln --symbolic "${hook_target}" "${hook_path}"
        fi
    fi
}

function uninstall_hook {
    git_dir="$1"
    admin_dir="$2"
    hook="$3"
    hook_path="${git_dir}/hooks/${hook}"
    hook_target="${admin_dir}/githooks.pl"

    if ! \test -a "${hook_path}"; then
        # If hook not exists, just write one
        \echo "No hook at ${hook_path}. Do nothing ..."
    else
        # Attn. We also check the target of the symlink!
        # It better be installed by us.
        if [[ $(\file "${hook_path}") == "${hook_path}: symbolic link to ${hook_target}" ]]; then
            \echo "Hook ${hook} exists. Remove..."
            \rm "${hook_path}"
            hook_d_path="${git_dir}/hooks.d/${hook}"
            if [[ -f "${hook_d_path}/${hook}" ]]; then
                echo "Return old hook ${hook_d_path}/${hook}."
                \mv "${hook_d_path}/${hook}" "${hook_path}"
            fi
        else
            echo "The hook file ${hook_path} is not a symlink. Do nothing ..."
        fi
    fi
}

# This is very rough parsing from the file, not very elegant.
function parse_cpanfile {
    filepath="$1"
    print_version="$2"
    while IFS= read -r line; do
        if [[ "$line" =~ 'requires ' ]]; then
            count="$(echo "$line" | \
                    \grep -E --count --max-count 1 'requires\s+'\''perl'\''\s+=>\s'\''')"
            if [[ $count -gt 0 ]]; then
                ver1=${line%\'*;}
                ver=${ver1##*=> \'}
                compatible="$(\perl -Mversion -Mfeature=say -e \
                    'say version->parse( $^V ) >= version->parse( $ver );')"
                if [[ "$compatible" != 1 ]]; then
                    echo "Perl version not compatible. Exiting ..."
                    exit 1
                fi
            else
                dep1=${line#* \'*}
                dep=${dep1%%\'*}
                ver1=${line%\'*;}
                ver=${ver1##*=> \'}
                if [[ $print_version = "" ]]; then
                    \echo -e "$dep"
                else
                    \echo -e "$dep $ver"
                fi
            fi
        fi
    done < "${filepath}"
}
