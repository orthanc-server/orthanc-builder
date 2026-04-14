#!/usr/bin/env bash
set -ex

# This script is only meant to be run inside Docker during the build process.
# It builds all Orthanc components individually and possibly try to download
# the component before if it has already been built.
# It possibly also uploads the components to public-files.orthanc.team/tmp-builds

# example
# for a CI build
# ./build-or-download baseImage=bullseye-20230703-slim commitId=xxxx target=orthanc preferDownloads=1 enableUploads=1
# for a local build
# ./build-or-download.sh target=orthanc baseImage=test commitId=68e15471b408 preferDownloads=1 enableUploads=1


# default arg values
target=unknown
preferDownloads=0
enableUploads=0
baseImage=unknown
commitId=xxx
extraArg1=
version=stable

for argument in "$@"
do
   key=$(echo $argument | cut -f1 -d=)

   key_length=${#key}
   value="${argument:$key_length+1}"

   export "$key"="$value"
done

echo "target             = $target"
echo "preferDownloads    = $preferDownloads"
echo "enableUploads      = $enableUploads"
echo "baseImage          = $baseImage"
echo "commitId           = $commitId"
echo "extraArg1          = $extraArg1"
echo "version            = $version"

# while debugging the script on your local machine, you might want to change these paths
# buildRootPath=/tmp/build
# sourcesRootPath=/tmp/sources
buildRootPath=/build
sourcesRootPath=/sources
dl=0

# rewrite pushd/popd such that they do not produce any output in bash functions (https://stackoverflow.com/questions/25288194/dont-display-pushd-popd-stack-across-several-bash-scripts-quiet-pushd-popd)
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

download() { # $1 file

    mkdir -p $buildRootPath
    already_built=$(($(curl --silent -I https://public-files.orthanc.team/tmp-builds/docker-builds/$baseImage/$commitId-$1 | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))
    if [[ $already_built == 1 ]]; then
        wget "https://public-files.orthanc.team/tmp-builds/docker-builds/$baseImage/$commitId-$1" --output-document $buildRootPath/$1
        echo 0
    else
        echo 1
    fi
}

upload() { # $1 file
    if [[ $enableUploads == 1 ]]; then
        echo "uploading $1";

        aws s3 --region eu-west-1 cp $buildRootPath/$1 s3://public-files.orthanc.team/tmp-builds/docker-builds/$baseImage/$commitId-$1 --cache-control=max-age=1
    else
        echo "skipping uploading of $1";
    fi
}

patch_version_name_on_unstable() { 
    # $1 needle (ex: "return mainline")
    # $2 file
    needle=$1
    file=$2
    replace=${3:-"return \"mainline-$commitId\""}

    if [[ $version == unstable ]]; then

        echo replacing "$needle" by "$replace" in "$file"
        sed -i "s/$needle/$replace/" $file

    fi
}

download_or_clone() {    # $1 = repoShortName $2 = commitId $3 = folder

    # try to download from a webserver instead of accessing the hg server that rejects many Azure IPs
    already_there=$(($(curl --silent -I https://public-files.orthanc.team/tmp-builds/hg-repos/$1-$2.tar.gz | grep -E "^HTTP"     | awk -F " " '{print $2}') == 200))
    if [[ $already_there == 1 ]]; then
        wget "https://public-files.orthanc.team/tmp-builds/hg-repos/$1-$2.tar.gz" --output-document /tmp/$1-$2.tar.gz

        mkdir -p $3
        pushd $3
        tar xvf /tmp/$1-$2.tar.gz --strip-components=1
        popd
        return 0
    else
        local max_retries=5
        local retry_delay=30  # seconds
        local attempt=1

        while [ $attempt -le $max_retries ]; do
            echo "Attempt $attempt of $max_retries..."
            if hg clone "https://orthanc.uclouvain.be/hg/$1" -r $2 $3; then
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
    fi
}

# link 3rd party downloads folder and download the mainline orthanc framework
link_third_party_downloads() { # $1 = target folder, $2 = download Orthanc mainline framework
    local download_framework=${2:-true}

    if [[ $download_framework == "true" ]]; then
        if [[ $version == "unstable" ]]; then
            wget https://public-files.orthanc.team/third-party-downloads/orthanc-framework/Orthanc-mainline.tar.gz --output-document /third-party-downloads/Orthanc-mainline.tar.gz
        fi
    fi

    ln -s /third-party-downloads $1
}

configure_orthanc_framework() { # $1 = cmake flags for orthanc framework for the stable release (usually empty)
    if [[ $version == "unstable" ]]; then
        mkdir /orthanc-framework
        wget https://public-files.orthanc.team/third-party-downloads/orthanc-framework/Orthanc-mainline.tar.gz --output-document /tmp/Orthanc-mainline.tar.gz --quiet
        pushd /orthanc-framework
        tar xf /tmp/Orthanc-mainline.tar.gz --strip-components=1 >/dev/null 2>&1
        echo "-DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/orthanc-framework/OrthancFramework/Sources"
        popd
    else
        echo $1
    fi
}

if [[ $target == "orthanc" ]]; then

    dl=$(( $dl + $(download Orthanc) ))
    dl=$(( $dl + $(download libModalityWorklists.so) ))
    dl=$(( $dl + $(download libServeFolders.so) ))
    dl=$(( $dl + $(download libHousekeeper.so) ))
    dl=$(( $dl + $(download libConnectivityChecks.so) ))
    dl=$(( $dl + $(download libDelayedDeletion.so) ))
    dl=$(( $dl + $(download libMultitenantDicom.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc $commitId $sourcesRootPath

        patch_version_name_on_unstable "result\[VERSION\] = ORTHANC_VERSION" $sourcesRootPath/OrthancServer/Sources/OrthancRestApi/OrthancRestSystem.cpp "result\[VERSION\] = \"mainline-$commitId\""
        patch_version_name_on_unstable "return MODALITY_WORKLISTS_VERSION" $sourcesRootPath/OrthancServer/Plugins/Samples/ModalityWorklists/Plugin.cpp
        patch_version_name_on_unstable "return SERVE_FOLDERS_VERSION" $sourcesRootPath/OrthancServer/Plugins/Samples/ServeFolders/Plugin.cpp
        patch_version_name_on_unstable "return HOUSEKEEPER_VERSION" $sourcesRootPath/OrthancServer/Plugins/Samples/Housekeeper/Plugin.cpp
        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/OrthancServer/Plugins/Samples/ConnectivityChecks/Plugin.cpp
        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/OrthancServer/Plugins/Samples/DelayedDeletion/Plugin.cpp
        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/OrthancServer/Plugins/Samples/MultitenantDicom/Plugin.cpp

        pushd $buildRootPath

        link_third_party_downloads $sourcesRootPath/OrthancServer/ThirdPartyDownloads
        # ln -s /third-party-downloads $sourcesRootPath/OrthancServer/ThirdPartyDownloads

        # note: building with static DCMTK because base images are often one version late
        # also force latest OpenSSL (and therefore, we need to force static libcurl)
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTANDALONE_BUILD=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF -DUSE_SYSTEM_DCMTK=OFF -DUSE_SYSTEM_OPENSSL=OFF -DUSE_SYSTEM_CURL=OFF -DUNIT_TESTS_WITH_HTTP_CONNEXIONS=OFF $sourcesRootPath/OrthancServer        
        make -j 4
        $buildRootPath/UnitTests

        upload Orthanc
        upload libModalityWorklists.so
        upload libServeFolders.so
        upload libHousekeeper.so
        upload libConnectivityChecks.so
        upload libDelayedDeletion.so
        upload libMultitenantDicom.so

    fi

elif [[ $target == "orthanc-authorization" ]]; then

    dl=$(( $dl + $(download libOrthancAuthorization.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-authorization $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/Plugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4
        $buildRootPath/UnitTests

        upload libOrthancAuthorization.so
    fi

elif [[ $target == "orthanc-python" ]]; then

    dl=$(( $dl + $(download libOrthancPython.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-python $commitId $sourcesRootPath

        patch_version_name_on_unstable "return PLUGIN_VERSION" $sourcesRootPath/Sources/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DPYTHON_VERSION=3.13 $sourcesRootPath
        make -j 4

        upload libOrthancPython.so
    fi

elif [[ $target == "orthanc-gdcm" ]]; then

    dl=$(( $dl + $(download libOrthancGdcm.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-gdcm $commitId $sourcesRootPath

        patch_version_name_on_unstable "return PLUGIN_VERSION" $sourcesRootPath/Plugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON $sourcesRootPath
        
        make -j 4

        upload libOrthancGdcm.so
    fi

elif [[ $target == "orthanc-pg" ]]; then

    dl=$(( $dl + $(download libOrthancPostgreSQLIndex.so) ))
    dl=$(( $dl + $(download libOrthancPostgreSQLStorage.so) ))

    if [[ $dl != 0 ]]; then

        # download_or_clone orthanc attach-custom-data /orthanc
        download_or_clone orthanc-databases $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/PostgreSQL/Plugins/IndexPlugin.cpp
        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/PostgreSQL/Plugins/StoragePlugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF  $sourcesRootPath/PostgreSQL
        # cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/orthanc/OrthancFramework/Sources -DORTHANC_SDK_VERSION=framework $sourcesRootPath/PostgreSQL
        make -j 4

        upload libOrthancPostgreSQLIndex.so
        upload libOrthancPostgreSQLStorage.so
    fi

elif [[ $target == "orthanc-mysql" ]]; then

    dl=$(( $dl + $(download libOrthancMySQLIndex.so) ))
    dl=$(( $dl + $(download libOrthancMySQLStorage.so) ))

    if [[ $dl != 0 ]]; then

        # download_or_clone orthanc attach-custom-data /orthanc

        download_or_clone orthanc-databases $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/MySQL/Plugins/IndexPlugin.cpp
        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/MySQL/Plugins/StoragePlugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        # TODO: we can remove -DUSE_SYSTEM_BOOST=OFF once the mysql plugin updates to a new release
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_BOOST=OFF $sourcesRootPath/MySQL
        # cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/orthanc/OrthancFramework/Sources -DORTHANC_SDK_VERSION=framework $sourcesRootPath/MySQL
        make -j 4

        upload libOrthancMySQLIndex.so
        upload libOrthancMySQLStorage.so
    fi


elif [[ $target == "orthanc-odbc" ]]; then

    dl=$(( $dl + $(download libOrthancOdbcIndex.so) ))
    dl=$(( $dl + $(download libOrthancOdbcStorage.so) ))

    if [[ $dl != 0 ]]; then

        # download_or_clone orthanc attach-custom-data /orthanc

        download_or_clone orthanc-databases $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/Odbc/Plugins/IndexPlugin.cpp
        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/Odbc/Plugins/StoragePlugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        # TODO: we can remove -DUSE_SYSTEM_BOOST=OFF once the odbc plugin updates to a new release
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_BOOST=OFF $sourcesRootPath/Odbc
        # cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/orthanc/OrthancFramework/Sources -DORTHANC_SDK_VERSION=framework $sourcesRootPath/Odbc
        make -j 4

        upload libOrthancOdbcIndex.so
        upload libOrthancOdbcStorage.so
    fi

elif [[ $target == "orthanc-indexer" ]]; then

    dl=$(( $dl + $(download libOrthancIndexer.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-indexer $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/Sources/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        # TODO: we can remove -DUSE_SYSTEM_BOOST=OFF once the neuro plugin updates to a more recent Framework (it is currently using 1.12.3).  It currently fails because of sha1.get_digest(digest);
        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_BOOST=OFF $sourcesRootPath
        make -j 4

        upload libOrthancIndexer.so
    fi

elif [[ $target == "orthanc-neuro" ]]; then

    dl=$(( $dl + $(download libOrthancNeuro.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-neuro $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/Sources/Plugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        # TODO: we can remove -DUSE_SYSTEM_BOOST=OFF once the neuro plugin updates to a more recent Framework (it is currently using 1.12.3).  It currently fails because of sha1.get_digest(digest);
        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_NIFTILIB=OFF -DUSE_SYSTEM_BOOST=OFF $sourcesRootPath
        make -j 4

        upload libOrthancNeuro.so
    fi

elif [[ $target == "orthanc-java" ]]; then

    dl=$(( $dl + $(download libOrthancJava.so) + $(download OrthancJavaSDK.jar)))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-java $commitId $sourcesRootPath

        patch_version_name_on_unstable "return PLUGIN_VERSION" $sourcesRootPath/Plugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath/Plugin
        make -j 4

        mkdir /buildJavaSDK
        pushd /buildJavaSDK
        cmake $framework_flags -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath/JavaSDK
        make
        mv /buildJavaSDK/OrthancJavaSDK.jar $buildRootPath/
        
        upload libOrthancJava.so
        upload OrthancJavaSDK.jar
    fi

elif [[ $target == "orthanc-stl" ]]; then

    dl=$(( $dl + $(download libOrthancSTL.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-stl $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_STL_VERSION" $sourcesRootPath/Sources/Plugin.cpp

        mkdir /sources/JavaScriptLibraries
        cd /sources/JavaScriptLibraries
        # CHANGE_VERSION_STL
        # wget https://orthanc.uclouvain.be/downloads/linux-standard-base/orthanc-stl/1.3/dist.zip --output-document dist.zip --quiet
        wget https://public-files.orthanc.team/lsb-mirror/STL-dist-1.3.zip --output-document dist.zip --quiet
        unzip dist.zip

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web -DORTHANC_FRAMEWORK_VERSION=1.12.5")

        pushd $buildRootPath
        # we build STL in static because it uses DCMTK and the DCMTK dynamic libraries are not installed (see in Orthanc section)
        # Note: we force the ORTHANC_FRAMEWORK_VERSION because the 1.12.4 uses DCMTK 3.6.8 that fails to build on ubuntu 25.10
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DSTATIC_BUILD=ON -DSTANDALONE_BUILD=ON -DCMAKE_BUILD_TYPE:STRING=Release $sourcesRootPath
        make -j 4

        upload libOrthancSTL.so
    fi

elif [[ $target == "orthanc-tcia" ]]; then

    dl=$(( $dl + $(download libOrthancTcia.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-tcia $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/Plugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        # TODO: we can remove -DUSE_SYSTEM_BOOST=OFF once the tcia plugin updates to a more recent Framework (it is currently using 1.12.3).  It currently fails because of sha1.get_digest(digest);
        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_LIBCSV=OFF -DUSE_SYSTEM_BOOST=OFF $sourcesRootPath
        make -j 4

        upload libOrthancTcia.so
    fi

elif [[ $target == "orthanc-explorer-2" ]]; then

    dl=$(( $dl + $(download libOrthancExplorer2.so) ))

    if [[ $dl != 0 ]]; then

        export DEBIAN_FRONTEND=noninteractive && apt-get --assume-yes update && apt-get --assume-yes install npm gnupg && apt-get clean && rm -rf /var/lib/apt/lists/*

        export DEBIAN_FRONTEND=noninteractive && \
            mkdir -p /etc/apt/keyrings && \
            curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
            echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
            apt-get update && apt-get install --assume-yes nodejs

        pushd $sourcesRootPath

        git clone https://github.com/orthanc-server/orthanc-explorer-2.git && \
        cd $sourcesRootPath/orthanc-explorer-2 && \
	    git checkout $commitId

        patch_version_name_on_unstable "return ORTHANC_OE2_VERSION" $sourcesRootPath/orthanc-explorer-2/Plugin/Plugin.cpp

        pushd $sourcesRootPath/orthanc-explorer-2/WebApplication

        npm install
        npm run build

        link_third_party_downloads $sourcesRootPath/orthanc-explorer-2/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF -DPLUGIN_VERSION=$extraArg1 $sourcesRootPath/orthanc-explorer-2/
        make -j 4

        upload libOrthancExplorer2.so
    fi

elif [[ $target == "orthanc-advanced-storage" ]]; then

    dl=$(( $dl + $(download libAdvancedStorage.so) ))

    if [[ $dl != 0 ]]; then

        # download_or_clone orthanc attach-custom-data /orthanc

        pushd $sourcesRootPath

        git clone https://github.com/orthanc-server/orthanc-advanced-storage.git && \
        cd $sourcesRootPath/orthanc-advanced-storage && \
	    git checkout $commitId

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/orthanc-advanced-storage/Plugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/orthanc-advanced-storage/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_PLUGIN_VERSION=$extraArg1  $sourcesRootPath/orthanc-advanced-storage/
        # cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/orthanc/OrthancFramework/Sources -DORTHANC_SDK_VERSION=framework $sourcesRootPath/orthanc-advanced-storage/

        make -j 4

        upload libAdvancedStorage.so
    fi

elif [[ $target == "orthanc-worklists" ]]; then

    dl=$(( $dl + $(download libOrthancWorklists.so) ))

    if [[ $dl != 0 ]]; then

        # download_or_clone orthanc attach-custom-data /orthanc

        pushd $sourcesRootPath

        git clone https://github.com/orthanc-server/orthanc-worklists.git && \
        cd $sourcesRootPath/orthanc-worklists && \
	    git checkout $commitId

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/orthanc-worklists/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/orthanc-worklists/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath/orthanc-worklists/
        # cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/orthanc/OrthancFramework/Sources -DORTHANC_SDK_VERSION=framework $sourcesRootPath/orthanc-worklists/

        make -j 4

        upload libOrthancWorklists.so
    fi

elif [[ $target == "orthanc-pixels-masker" ]]; then

    dl=$(( $dl + $(download libOrthancPixelsMasker.so) ))

    if [[ $dl != 0 ]]; then

        # download_or_clone orthanc attach-custom-data /orthanc

        pushd $sourcesRootPath

        git clone https://github.com/orthanc-server/orthanc-pixels-masker.git && \
        cd $sourcesRootPath/orthanc-pixels-masker && \
	    git checkout $commitId

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/orthanc-pixels-masker/Sources/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/orthanc-pixels-masker/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath/orthanc-pixels-masker/
        # cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_FRAMEWORK_SOURCE=path -DORTHANC_FRAMEWORK_ROOT=/orthanc/OrthancFramework/Sources -DORTHANC_SDK_VERSION=framework $sourcesRootPath/orthanc-worklists/

        make -j 4

        upload libOrthancPixelsMasker.so
    fi

elif [[ $target == "download-orthanc-volview-dist" ]]; then

    dl=$(( $dl + $(download VolView-dist.zip) ))

    if [[ $dl != 0 ]]; then

        echo "Failed to download VolView web build.  You are likely running a build on ARM64 and needs the AMD64 build to have pushed the WEB build on a web server"
        exit 1
    fi

elif [[ $target == "orthanc-volview-from-dist" ]]; then

    dl=$(( $dl + $(download libOrthancVolView.so) ))

    if [[ $dl != 0 ]]; then
        # build only the C++ code, not the dist.zip that has been downloaded before

        pushd $sourcesRootPath
        download_or_clone orthanc-volview $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_VOLVIEW_VERSION" $sourcesRootPath/Sources/Plugin.cpp

        # unzip the file at the right place for the next step (it will unzip it in $sourcesRootPath/VolView/dist/...)
        pushd /
        unzip $buildRootPath/VolView-dist.zip

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4

        upload libOrthancVolView.so
    fi

elif [[ $target == "orthanc-volview" ]]; then

    dl=$(( $dl + $(download libOrthancVolView.so) ))

    if [[ $dl != 0 ]]; then
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
        source /root/.bashrc
        export NVM_DIR="/root/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

        nvm install v19.7.0

        pushd $sourcesRootPath
        download_or_clone orthanc-volview $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_VOLVIEW_VERSION" $sourcesRootPath/Sources/Plugin.cpp

        # extract the version number (remove all lines with comments and the line with VERSION=$1)
        volview_version=$(cat $sourcesRootPath/Resources/CreateVolViewDist.sh | grep 'VERSION=' | grep -v '#' | grep -v '\$' | cut -d'=' -f2)

        # CreateVolViewDist/build.sh needs to work with /target and /source
        # wget https://orthanc.uclouvain.be/downloads/third-party-downloads/VolView-${volview_version}.tar.gz --quiet --output-document $sourcesRootPath/VolView-${volview_version}.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/VolView-${volview_version}.tar.gz --quiet --output-document $sourcesRootPath/VolView-${volview_version}.tar.gz

        # CreateVolViewDist/build.sh needs /target and /source while $sourcesRootPath usually points to /sources
        mkdir /target
        mkdir /source
        cp -r $sourcesRootPath/* /source
        chmod +x /source/Resources/CreateVolViewDist/build.sh
        /source/Resources/CreateVolViewDist/build.sh ${volview_version}
        mkdir -p $sourcesRootPath/VolView
        cp -r /target $sourcesRootPath/VolView/dist

        zip -r $buildRootPath/VolView-dist.zip $sourcesRootPath/VolView/dist
        upload VolView-dist.zip

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4

        upload libOrthancVolView.so
    fi

elif [[ $target == "download-orthanc-ohif-dist" ]]; then

    dl=$(( $dl + $(download OHIF-dist.zip) ))

    if [[ $dl != 0 ]]; then

        echo "Failed to download OHIF web build.  You are likely running a build on ARM64 and needs the AMD64 build to have pushed the WEB build on a web server"
        exit 1
    fi

elif [[ $target == "orthanc-ohif-from-dist" ]]; then

    dl=$(( $dl + $(download libOrthancOHIF.so) ))

    if [[ $dl != 0 ]]; then
        # build only the C++ code, not the dist.zip that has been downloaded before

        pushd $sourcesRootPath
        download_or_clone orthanc-ohif $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_OHIF_VERSION" $sourcesRootPath/Sources/Plugin.cpp

        # unzip the file at the right place for the next step (it will unzip it in $sourcesRootPath/OHIF/dist/...)
        pushd /
        unzip $buildRootPath/OHIF-dist.zip

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web -DORTHANC_FRAMEWORK_VERSION=1.12.10") # force framework 1.12.10 because of FindPythonInterp)

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4

        upload libOrthancOHIF.so
    fi

elif [[ $target == "orthanc-ohif" ]]; then

    dl=$(( $dl + $(download libOrthancOHIF.so) ))

    if [[ $dl != 0 ]]; then

        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
        source /root/.bashrc
        export NVM_DIR="/root/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

        nvm install v20.18.1
        npm install --global bun@1.2.23
        npm install --global lerna@7.4.2
        npm install --global yarn

        pushd $sourcesRootPath
        download_or_clone orthanc-ohif $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_OHIF_VERSION" $sourcesRootPath/Sources/Plugin.cpp
        ohif_version=$(cat $sourcesRootPath/Resources/CreateOHIFDist.sh | grep -oP 'PACKAGE=Viewers-\K\d+\.\d+\.\d+')

        # wget https://orthanc.uclouvain.be/downloads/third-party-downloads/OHIF/Viewers-${ohif_version}.tar.gz --quiet --output-document $sourcesRootPath/Viewers-${ohif_version}.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/OHIF/Viewers-${ohif_version}.tar.gz --quiet --output-document $sourcesRootPath/Viewers-${ohif_version}.tar.gz

        # CreateOHIFDist/build.sh needs /target and /source while $sourcesRootPath usually points to /sources
        mkdir /target
        mkdir /source
        cp -r $sourcesRootPath/* /source
        chmod +x /source/Resources/CreateOHIFDist/build.sh
        /source/Resources/CreateOHIFDist/build.sh Viewers-${ohif_version}
        mkdir -p $sourcesRootPath/OHIF
        cp -r /target $sourcesRootPath/OHIF/dist
        zip -r $buildRootPath/OHIF-dist.zip $sourcesRootPath/OHIF/dist
        upload OHIF-dist.zip

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web -DORTHANC_FRAMEWORK_VERSION=1.12.10") # force framework 1.12.10 because of FindPythonInterp

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4

        upload libOrthancOHIF.so
    fi

elif [[ $target == "orthanc-s3" ]]; then

    dl=$(( $dl + $(download libOrthancAwsS3Storage.so) ))

    if [[ $dl != 0 ]]; then

        export DEBIAN_FRONTEND=noninteractive && apt-get --assume-yes update && apt-get --assume-yes install libcrypto++-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

        # TODO: we can remove -DUSE_SYSTEM_BOOST=OFF once the object-storage plugin updates to a new release
        cd $sourcesRootPath
        download_or_clone orthanc-object-storage $commitId $sourcesRootPath

        patch_version_name_on_unstable "return PLUGIN_VERSION" $sourcesRootPath/Common/StoragePlugin.cpp

        pushd $buildRootPath

        link_third_party_downloads $sourcesRootPath/Aws/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        cmake $framework_flags -DCMAKE_BUILD_TYPE:STRING=Release -DALLOW_DOWNLOADS=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_VCPKG_PACKAGES=OFF -DUSE_SYSTEM_BOOST=OFF $sourcesRootPath/Aws/
        make -j 4

        upload libOrthancAwsS3Storage.so
    fi

elif [[ $target == "orthanc-google-storage" ]]; then

    dl=$(( $dl + $(download libOrthancGoogleCloudStorage.so) ))

    if [[ $dl != 0 ]]; then

        export DEBIAN_FRONTEND=noninteractive && apt-get --assume-yes update && apt-get --assume-yes install libcrypto++-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

        # TODO: we can remove -DUSE_SYSTEM_BOOST=OFF once the object-storage plugin updates to a new release
        cd $sourcesRootPath
        download_or_clone orthanc-object-storage $commitId $sourcesRootPath

        patch_version_name_on_unstable "return PLUGIN_VERSION" $sourcesRootPath/Common/StoragePlugin.cpp

        link_third_party_downloads $sourcesRootPath/Google/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath

        cmake $framework_flags -DCMAKE_BUILD_TYPE:STRING=Release -DALLOW_DOWNLOADS=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_BOOST=OFF -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake $sourcesRootPath/Google/
        make -j 4

        upload libOrthancGoogleCloudStorage.so
    fi


elif [[ $target == "orthanc-azure-storage" ]]; then

    dl=$(( $dl + $(download libOrthancAzureBlobStorage.so) ))

    if [[ $dl != 0 ]]; then

        export DEBIAN_FRONTEND=noninteractive && apt-get --assume-yes update && apt-get --assume-yes install libcrypto++-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

        cd $sourcesRootPath
        download_or_clone orthanc-object-storage $commitId $sourcesRootPath

        patch_version_name_on_unstable "return PLUGIN_VERSION" $sourcesRootPath/Common/StoragePlugin.cpp

        link_third_party_downloads $sourcesRootPath/Azure/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        # TODO: we can remove -DUSE_SYSTEM_BOOST=OFF once the object-storage plugin updates to a new release
        pushd $buildRootPath

        cmake $framework_flags -DCMAKE_BUILD_TYPE:STRING=Release -DALLOW_DOWNLOADS=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_BOOST=OFF -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake $sourcesRootPath/Azure/
        make -j 4

        upload libOrthancAzureBlobStorage.so
    fi

elif [[ $target == "orthanc-webviewer" ]]; then

    dl=$(( $dl + $(download libOrthancWebViewer.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-webviewer $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/Plugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4
        $buildRootPath/UnitTests

        upload libOrthancWebViewer.so
    fi

elif [[ $target == "orthanc-transfers" ]]; then

    dl=$(( $dl + $(download libOrthancTransfers.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-transfers $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/Plugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4
        $buildRootPath/UnitTests

        upload libOrthancTransfers.so
    fi


elif [[ $target == "orthanc-dicomweb" ]]; then

    dl=$(( $dl + $(download libOrthancDicomWeb.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-dicomweb $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_DICOM_WEB_VERSION" $sourcesRootPath/Plugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4
        $buildRootPath/UnitTests

        upload libOrthancDicomWeb.so
    fi

elif [[ $target == "orthanc-wsi" ]]; then

    dl=$(( $dl + $(download libOrthancWSI.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-wsi $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_WSI_VERSION" $sourcesRootPath/ViewerPlugin/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_OPENJPEG=OFF $sourcesRootPath/ViewerPlugin
        make -j 4

        # TODO: build dicomizer tools ?

        upload libOrthancWSI.so

    fi

elif [[ $target == "download-orthanc-stone-wasm" ]]; then

    dl=$(( $dl + $(download stone.wasm.tar.gz) ))

    if [[ $dl != 0 ]]; then

        echo "Failed to download WASM build.  You are likely running abuild on ARM64 and needs the AMD64 build to have pushed the WASM on a web server"
        exit 1
    else

        # since this is a multi-stage build, we must uncompress the tar.gz where the next step expects it (in /target)
        mkdir -p /target
        pushd /target
        tar xvf $buildRootPath/stone.wasm.tar.gz

    fi

elif [[ $target == "orthanc-stone-wasm" ]]; then

    dl=$(( $dl + $(download stone.wasm.tar.gz) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-stone $commitId /source

        mkdir -p /source/Applications/StoneWebViewer/WebAssembly/ThirdPartyDownloads
        pushd /source/Applications/StoneWebViewer/WebAssembly/ThirdPartyDownloads
        wget https://public-files.orthanc.team/third-party-downloads/pdfjs-2.5.207-dist.zip
        wget https://public-files.orthanc.team/third-party-downloads/jquery-3.7.1.min.js
        wget https://public-files.orthanc.team/third-party-downloads/axios-1.7.5.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/vue-2.6.14.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/bootstrap-3.4.1-dist.zip
        wget https://public-files.orthanc.team/third-party-downloads/fontawesome-free-5.14.0-web.zip
        wget https://public-files.orthanc.team/third-party-downloads/ubuntu-font-family-0.83.zip
        wget https://public-files.orthanc.team/third-party-downloads/pixman-0.34.0.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/freetype-2.9.1.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/cairo-1.14.12.tar.xz
        wget https://public-files.orthanc.team/third-party-downloads/dcmtk-3.7.0.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/boost_1_89_0_bcpdigest-1.12.11.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/e2fsprogs-1.44.5.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/jsoncpp-1.9.5.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/pugixml-1.14.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/libpng-1.6.50.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/zlib-1.3.1.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/jpegsrc.v9f.tar.gz
        wget https://public-files.orthanc.team/third-party-downloads/orthanc-framework/Orthanc-mainline.tar.gz
        popd

        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web -DORTHANC_FRAMEWORK_VERSION=1.12.10")
        cp /third-party-downloads/* /source/Applications/StoneWebViewer/WebAssembly/ThirdPartyDownloads 

        ls -al /source/Applications/StoneWebViewer/WebAssembly/ThirdPartyDownloads

        # equivalent of docker-internal.sh from orthanc-stone repo
        source /opt/emsdk/emsdk_env.sh

        # Use a folder that is writeable by non-root users for the Emscripten cache
        export EM_CACHE=/tmp/emscripten-cache

        mkdir -p $buildRootPath
        pushd $buildRootPath
        cmake $framework_flags -DORTHANC_STONE_INSTALL_PREFIX=/target/StoneWebViewer -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_TOOLCHAIN_FILE=${EMSDK}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -DSTATIC_BUILD=ON -DLIBCLANG=/usr/lib/llvm-4.0/lib/libclang-4.0.so /source/Applications/StoneWebViewer/WebAssembly
        make -j 8
        make install

        pushd /target
        tar -zcvf $buildRootPath/stone.wasm.tar.gz StoneWebViewer/

        upload stone.wasm.tar.gz

        if [[ $enableUploads == 1 ]]; then
            aws s3 --region eu-west-1 cp $buildRootPath/stone.wasm.tar.gz s3://public-files.orthanc.team/tmp-builds/nightly-stone-wasm-builds/$version/wasm-binaries.zip --cache-control=max-age=1
        fi

    else

        # since this is a multi-stage build, we must uncompress the tar.gz where the next step expects it (in /target)
        mkdir -p /target
        pushd /target
        tar xvf $buildRootPath/stone.wasm.tar.gz

    fi

elif [[ $target == "orthanc-stone-so" ]]; then

    dl=$(( $dl + $(download libStoneWebViewer.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-stone $commitId $sourcesRootPath

        # StoneViewer is quite often on a non stable branch even in the stable build -> if its version is "mainline", always append the commit id
        if grep -q "set(STONE_WEB_VIEWER_VERSION \"mainline\")" "$sourcesRootPath/Applications/StoneWebViewer/Version.cmake"; then
            patch_version_name_on_unstable "return PLUGIN_VERSION" $sourcesRootPath/Applications/StoneWebViewer/Plugin/Plugin.cpp
        fi

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web -DORTHANC_FRAMEWORK_VERSION=1.12.10")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_STONE_BINARIES=/downloads/wasm-binaries/StoneWebViewer $sourcesRootPath/Applications/StoneWebViewer/Plugin/
        make -j 4

        upload libStoneWebViewer.so

    fi

elif [[ $target == "orthanc-education" ]]; then

    dl=$(( $dl + $(download libOrthancEducation.so) ))

    if [[ $dl != 0 ]]; then

        download_or_clone orthanc-education $commitId $sourcesRootPath

        patch_version_name_on_unstable "return ORTHANC_PLUGIN_VERSION" $sourcesRootPath/Sources/Plugin.cpp

        link_third_party_downloads $sourcesRootPath/ThirdPartyDownloads
        framework_flags=$(configure_orthanc_framework "-DORTHANC_FRAMEWORK_SOURCE=web")

        pushd $buildRootPath
        cmake $framework_flags -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j4

        upload libOrthancEducation.so
    fi

fi
