#!/bin/bash

# rewrite pushd/popd such that they do not produce any output in bash functions (https://stackoverflow.com/questions/25288194/dont-display-pushd-popd-stack-across-several-bash-scripts-quiet-pushd-popd)
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}


getFromMatrix() { # $1 = name, $2 = field, $3 = defaultValue
    value=$(cat build-matrix.json | jq -r ".configs[] | select( .name == \"$1\").$2")
    if [[ $value == "null" ]]; then
        echo $3
    else
        echo $value
    fi
}

getIntegTestsRevision() { # $1 = stable/unstable
    value=$(cat build-matrix.json | jq -r ".integrationTests.$1")    
    echo $value
}

getArtifactsMacOS() { # $1 = name, $2 = version (stable or unstable) 
    if [[ $2 == "unstable" ]]; then

        artifacts=$(getFromMatrix $1 unstableArtifactsMacOS)

        if [[ $artifacts == "" ]]; then
            artifacts=$(getFromMatrix $1 artifactsMacOS)
        fi

    else

        artifacts=$(getFromMatrix $1 artifactsMacOS)

    fi

    echo $artifacts
}

getBranchTagToBuildMacOS() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then

        revision=$(getFromMatrix $1 stableMacOS)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 stable)
        fi

    else

        revision=$(getFromMatrix $1 unstableMacOS)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 unstable)
        fi

    fi

    echo $revision
}

getPrebuildStepMacOS() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then
        prebuild=$(getFromMatrix $1 preBuildStableMacOS "")
    else
        prebuild=$(getFromMatrix $1 preBuildUnstableMacOS "")
    fi

    echo $prebuild
}

getCustomBuildMacOS() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then
        prebuild=$(getFromMatrix $1 customBuildMacOS "")
    else
        prebuild=$(getFromMatrix $1 customBuildMacOS "")
    fi

    echo $prebuild
}

getArtifactsWin() { # $1 = name, $2 = version (stable or unstable) 
    if [[ $2 == "unstable" ]]; then

        artifacts=$(getFromMatrix $1 unstableArtifactsWin)

        if [[ $artifacts == "" ]]; then
            artifacts=$(getFromMatrix $1 artifactsWin)
        fi

    else

        artifacts=$(getFromMatrix $1 artifactsWin)

    fi

    echo $artifacts
}

getBranchTagToBuildWin() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then

        revision=$(getFromMatrix $1 stableWin)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 stable)
        fi

    else

        revision=$(getFromMatrix $1 unstableWin)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 unstable)
        fi

    fi

    echo $revision
}

getPrebuildStepWin() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then
        prebuild=$(getFromMatrix $1 preBuildStableWin "")

        if [[ $prebuild == "" ]]; then
            prebuild=$(getFromMatrix $1 preBuildWin "")
        fi
    else
        prebuild=$(getFromMatrix $1 preBuildUnstableWin "")

        if [[ $prebuild == "" ]]; then
            prebuild=$(getFromMatrix $1 preBuildWin "")
        fi
    fi

    echo $prebuild
}

getCustomBuildWin() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then
        prebuild=$(getFromMatrix $1 customBuildWin "")
    else
        prebuild=$(getFromMatrix $1 customBuildWin "")
    fi

    echo $prebuild
}


getBranchTagToBuildDocker() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then

        revision=$(getFromMatrix $1 stableDocker)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 stable)
        fi

    else

        revision=$(getFromMatrix $1 unstableDocker)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 unstable)
        fi

    fi

    echo $revision
}

getBranchTagToBuildWin() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then

        revision=$(getFromMatrix $1 stableWin)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 stable)
        fi

    else

        revision=$(getFromMatrix $1 unstableWin)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 unstable)
        fi

    fi

    echo $revision
}

getHgCommitId() { # $1 = repo, $2 = branch/tag/revision
    commit_id=$(hg identify $1 -r $2)
    echo $commit_id
}

getGitCommitId() { # $1 = repo, $2 = branch/tag/revision
    tmp=$(mktemp -d -t git-check-last-commit-XXXXXXXXXXX)
    git clone --quiet --filter=blob:none --no-checkout $1 $tmp
    pushd $tmp
    git checkout $2 &> /dev/null
    local commit_id=$(git rev-parse $2)
    popd
    rm -rf $tmp

    echo $commit_id
}

getCommitId() { # $1 = name, $2 = version (stable or unstable), $3 = platform (macos/win/docker), $4 = skipCommitCheck (0/1)

    if [[ $3 == "macos" ]]; then
        revision=$(getBranchTagToBuildMacOS $1 $2)
    elif [[ $3 == "win" ]]; then
        revision=$(getBranchTagToBuildWin $1 $2)
    else
        revision=$(getBranchTagToBuildDocker $1 $2)
    fi

    if [[ $4 == "1" ]]; then
        echo $revision
        return
    fi

    # get the last commit id for this revision
    repo=$(getFromMatrix $1 repo)
    repoType=$(getFromMatrix $1 repoType)
    
    if [[ $repoType == "hg" ]]; then

        commit_id=$(getHgCommitId $repo $revision)

    elif [[ $repoType == "git" ]]; then

        commit_id=$(getGitCommitId $repo $revision)

    fi

    echo $commit_id
}
