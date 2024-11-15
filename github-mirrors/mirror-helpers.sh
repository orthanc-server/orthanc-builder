#!/bin/bash

# rewrite pushd/popd such that they do not produce any output in bash functions (https://stackoverflow.com/questions/25288194/dont-display-pushd-popd-stack-across-several-bash-scripts-quiet-pushd-popd)
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

initVirtualEnv() {
    python -m venv .env
    source .env/bin/activate
    pip install mercurial hg-git
}

firstCloneMercurialRepo() { # $1 = repo-name
    pushd $script_dir/mirrors/
    hg clone https://orthanc.uclouvain.be/hg/$1

    cat << EOF >> $1/.hg/hgrc
[extensions]
hggit=
hgext.bookmarks =
EOF

    sed -i "/^default =/a\github = git+ssh://git@github.com:orthanc-mirrors/$1.git" $1/.hg/hgrc
    cat $1/.hg/hgrc
    pushd $script_dir/mirrors/$1
    
    hg bookmark master
    hg push github

    popd
    
    popd
}

syncRepoBranch() { # $1 = repo-name, $2 = branch-name
    pushd $script_dir/mirrors/$1

    # hg pull -u
    hg update -r $2
    # hg pull -u

    if [ "$2" == "default" ]; then
        hg bookmark master
    else
        hg bookmark branches/$2
    fi

    hg push github || true

    popd
}

listAllBranches() { # $1 = repo-name
    hg branches | awk '{print $1}'
}

syncAllBranchesFromRepo() { # $1 = repo-name

    if [ ! -d "$script_dir/mirrors/$1" ]; then
        firstCloneMercurialRepo $1
    fi

    pushd $script_dir/mirrors/$1
    
    hg pull -u

    # Get all active branch names and iterate through them
    hg branches | awk '{print $1}' | while read branch_name; do
        syncRepoBranch $1 "$branch_name"
    done

    popd
}
