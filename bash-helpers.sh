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

getHgRepoShortName() { # $1 = repo url (https://orthanc.uclouvain.be/hg/orthanc-databases/)
    repoShortName=$(echo "$1" | grep -oP '(?<=hg\/).*(?=\/)')
    echo $repoShortName
}

getCommitId() { # $1 = name, $2 = version (stable or unstable), $3 = platform (macos/win/docker), $4 = skipCommitCheck (0/1), $5 = throttle (0/1) $6 = uploadToWebServer

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

    if [[ $5 == "1" ]]; then
        # throttle on CI because we get a lot of bad gateway errors on UCLouvain server
        sleep 1
    fi

    # get the last commit id for this revision
    repo=$(getFromMatrix $1 repo)
    repoType=$(getFromMatrix $1 repoType)
    
    if [[ $repoType == "hg" ]]; then

        commit_id=$(getHgCommitId $repo $revision)
        repoShortName=$(getHgRepoShortName $repo)

        if [[ $uploadToWebServer == "1" ]]; then
            upload_hg_repo_to_orthanc_team_if_not_already_there $repoShortName $commit_id $repo
        fi

    elif [[ $repoType == "git" ]]; then

        commit_id=$(getGitCommitId $repo $revision)

    fi

    echo $commit_id
}

hgCloneWithRetries() {
    local max_retries=5
    local retry_delay=30  # seconds
    local attempt=1

    while [ $attempt -le $max_retries ]; do
        echo "Attempt $attempt of $max_retries..."
        if hg clone "$@"; then
            echo "Clone succeeded."
            return 0
        else
            if [ $attempt -lt $max_retries ]; then
                echo "Clone failed. Retrying in $retry_delay seconds..."
                sleep $retry_delay
                # Double the delay for the next attempt (exponential backoff)
                retry_delay=$((retry_delay * 2))                
            else
                echo "Clone failed after $max_retries attempts."
                return 1
            fi
        fi
        ((attempt++))
    done
}

download_hg_repo_from_orthanc_team() { # $1 repoShortName $2 commitId $3 repo-url

    mkdir -p $buildRootPath
    already_there=$(($(curl --silent -I https://public-files.orthanc.team/tmp-builds/hg-repos/$1-$commitId | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))
    if [[ $already_there == 1 ]]; then
        wget "https://public-files.orthanc.team/tmp-builds/hg-repos/$1-$commitId" --output-document $buildRootPath/$1
        echo 0
    else
        echo 1
    fi
}

upload_hg_repo_to_orthanc_team_if_not_already_there() { # $1 repoShortName $2 commitId $3 repo-url
    already_there=$(($(curl --silent -I https://public-files.orthanc.team/tmp-builds/hg-repos/$1-$2.tar.gz | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))
    if [[ $already_there == 0 ]]; then
        rm -rf /tmp/$1
        hgCloneWithRetries $3 -r $2 /tmp/$1
        pushd /tmp/$1
        hg archive /tmp/$1-$2.tar.gz

        echo "uploading hg-repo $1";

        aws s3 --region eu-west-1 cp /tmp/$1-$2.tar.gz s3://public-files.orthanc.team/tmp-builds/hg-repos/$1-$2.tar.gz --cache-control=max-age=1
    else
        echo "skipping uploading of $1-$2.tar.gz - already on the webserver";
    fi
}
