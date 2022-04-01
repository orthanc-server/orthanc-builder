#!/bin/bash

getFromMatrix() { # $1 = name, $2 = field, $3 = defaultValue
    value=$(cat build-matrix.json | jq -r ".configs[] | select( .name == \"$1\").$2")
    if [[ $value == "null" ]]; then
        echo $3
    else
        echo $value
    fi
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
