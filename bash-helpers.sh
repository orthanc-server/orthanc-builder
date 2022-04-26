#!/bin/bash

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

getArtifactsOSX() { # $1 = name, $2 = version (stable or unstable) 
    if [[ $2 == "unstable" ]]; then

        artifacts=$(getFromMatrix $1 unstableArtifactsOSX)

        if [[ $artifacts == "" ]]; then
            artifacts=$(getFromMatrix $1 artifactsOSX)
        fi

    else

        artifacts=$(getFromMatrix $1 artifactsOSX)

    fi

    echo $artifacts
}

getBranchTagToBuildOSX() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then

        revision=$(getFromMatrix $1 stableOSX)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 stable)
        fi

    else

        revision=$(getFromMatrix $1 unstableOSX)

        if [[ $revision == "" ]]; then
            revision=$(getFromMatrix $1 unstable)
        fi

    fi

    echo $revision
}

getPrebuildStepOSX() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then
        prebuild=$(getFromMatrix $1 preBuildStableOSX "")
    else
        prebuild=$(getFromMatrix $1 preBuildUnstableOSX "")
    fi

    echo $prebuild
}

getCustomBuildOSX() { # $1 = name, $2 = version (stable or unstable)
    if [[ $2 == "stable" ]]; then
        prebuild=$(getFromMatrix $1 customBuildOSX "")
    else
        prebuild=$(getFromMatrix $1 customBuildOSX "")
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


getCommitId() { # $1 = name, $2 = version (stable or unstable), $3 = platform (osx/win/docker), $4 = skipCommitCheck (0/1)

    if [[ $3 == "osx" ]]; then
        revision=$(getBranchTagToBuildOSX $1 $2)
    elif [[ $3 == "win" ]]; then
        exit 1 # TODO
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

        tmp=$(mktemp -d -t git-check-last-commit-XXXXXXXXXXX)
        git clone --filter=blob:none --no-checkout  https://bitbucket.org/osimis/osimis-webviewer-plugin/ $tmp
        pushd $tmp
        commit_id=$(git rev-parse $revision)
        popd

    fi

    echo $commit_id
}
