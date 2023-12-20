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

if [[ $target == "orthanc" ]]; then

    dl=$(( $dl + $(download Orthanc) ))
    dl=$(( $dl + $(download libModalityWorklists.so) ))
    dl=$(( $dl + $(download libServeFolders.so) ))
    dl=$(( $dl + $(download libHousekeeper.so) ))
    dl=$(( $dl + $(download libConnectivityChecks.so) ))
    dl=$(( $dl + $(download libDelayedDeletion.so) ))
    dl=$(( $dl + $(download libMultitenantDicom.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc/ -r $commitId $sourcesRootPath
        pushd $buildRootPath

        # note: building with static DCMTK while waiting for Debian bullseye to update to latest DCMTK issues (we need DCMTK 3.6.7: https://www.hipaajournal.com/warning-issued-about-3-high-severity-vulnerabilities-in-offis-dicom-software/)
        # also force latest OpenSSL (and therefore, we need to force static libcurl)
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTANDALONE_BUILD=ON -DUSE_GOOGLE_TEST_DEBIAN_PACKAGE=ON -DUSE_SYSTEM_CIVETWEB=OFF -DUSE_SYSTEM_DCMTK=OFF -DUSE_SYSTEM_OPENSSL=OFF -DUSE_SYSTEM_CURL=OFF $sourcesRootPath/OrthancServer
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

        hg clone https://orthanc.uclouvain.be/hg/orthanc-authorization/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4
        $buildRootPath/UnitTests

        upload libOrthancAuthorization.so
    fi

elif [[ $target == "orthanc-python" ]]; then

    dl=$(( $dl + $(download libOrthancPython.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-python/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DPYTHON_VERSION=3.9 $sourcesRootPath
        make -j 4

        upload libOrthancPython.so
    fi

elif [[ $target == "orthanc-gdcm" ]]; then

    dl=$(( $dl + $(download libOrthancGdcm.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-gdcm/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DSTATIC_BUILD=ON $sourcesRootPath
        make -j 4

        upload libOrthancGdcm.so
    fi

elif [[ $target == "orthanc-pg" ]]; then

    dl=$(( $dl + $(download libOrthancPostgreSQLIndex.so) ))
    dl=$(( $dl + $(download libOrthancPostgreSQLStorage.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-databases/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath/PostgreSQL
        make -j 4

        upload libOrthancPostgreSQLIndex.so
        upload libOrthancPostgreSQLStorage.so
    fi

elif [[ $target == "orthanc-mysql" ]]; then

    dl=$(( $dl + $(download libOrthancMySQLIndex.so) ))
    dl=$(( $dl + $(download libOrthancMySQLStorage.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-databases/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath/MySQL
        make -j 4

        upload libOrthancMySQLIndex.so
        upload libOrthancMySQLStorage.so
    fi

elif [[ $target == "orthanc-odbc" ]]; then

    dl=$(( $dl + $(download libOrthancOdbcIndex.so) ))
    dl=$(( $dl + $(download libOrthancOdbcStorage.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-databases/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath/Odbc
        make -j 4

        upload libOrthancOdbcIndex.so
        upload libOrthancOdbcStorage.so
    fi

elif [[ $target == "orthanc-indexer" ]]; then

    dl=$(( $dl + $(download libOrthancIndexer.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-indexer/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_LIBCSV=OFF $sourcesRootPath
        make -j 4

        upload libOrthancIndexer.so
    fi

elif [[ $target == "orthanc-neuro" ]]; then

    dl=$(( $dl + $(download libOrthancNeuro.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-neuro/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_NIFTILIB=OFF $sourcesRootPath
        make -j 4

        upload libOrthancNeuro.so
    fi

elif [[ $target == "orthanc-tcia" ]]; then

    dl=$(( $dl + $(download libOrthancTcia.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-tcia/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_LIBCSV=OFF $sourcesRootPath
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

        pushd $sourcesRootPath/orthanc-explorer-2/WebApplication

        npm install
        npm run build

        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF -DPLUGIN_VERSION=$extraArg1 $sourcesRootPath/orthanc-explorer-2/
        make -j 4

        upload libOrthancExplorer2.so
    fi

elif [[ $target == "orthanc-volview" ]]; then

    dl=$(( $dl + $(download libOrthancVolView.so) ))

    if [[ $dl != 0 ]]; then
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
        source /root/.bashrc
        nvm install v19.7.0

        pushd $sourcesRootPath
        hg clone https://orthanc.uclouvain.be/hg/orthanc-volview/ -r $commitId $sourcesRootPath

        # CreateVolViewDist/build.sh needs to work with /target and /source
        wget https://orthanc.uclouvain.be/third-party-downloads/VolView-${extraArg1}.tar.gz --quiet --output-document $sourcesRootPath/VolView-${extraArg1}.tar.gz
        cp $sourcesRootPath/VolView/VolView-*.patch $sourcesRootPath

        # CreateVolViewDist/build.sh needs /target and /source while $sourcesRootPath usually points to /sources
        mkdir /target
        mkdir /source
        cp -r $sourcesRootPath/* /source
        chmod +x /source/Resources/CreateVolViewDist/build.sh
        /source/Resources/CreateVolViewDist/build.sh ${extraArg1}
        mkdir -p $sourcesRootPath/VolView
        cp -r /target $sourcesRootPath/VolView/dist
        
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4

        upload libOrthancVolView.so
    fi

elif [[ $target == "orthanc-ohif" ]]; then

    dl=$(( $dl + $(download libOrthancOHIF.so) ))

    if [[ $dl != 0 ]]; then

        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
        source /root/.bashrc
        nvm install v20.3.0
        npm install --global yarn

        pushd $sourcesRootPath
        hg clone https://orthanc.uclouvain.be/hg/orthanc-ohif/ -r $commitId $sourcesRootPath

        wget https://orthanc.uclouvain.be/third-party-downloads/OHIF/Viewers-${extraArg1}.tar.gz --quiet --output-document $sourcesRootPath/Viewers-${extraArg1}.tar.gz

        # CreateOHIFDist/build.sh needs /target and /source while $sourcesRootPath usually points to /sources
        mkdir /target
        mkdir /source
        cp -r $sourcesRootPath/* /source
        chmod +x /source/Resources/CreateOHIFDist/build.sh
        /source/Resources/CreateOHIFDist/build.sh Viewers-${extraArg1}
        mkdir -p $sourcesRootPath/OHIF
        cp -r /target $sourcesRootPath/OHIF/dist
        
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4

        upload libOrthancOHIF.so
    fi

elif [[ $target == "orthanc-s3" ]]; then

    dl=$(( $dl + $(download libOrthancAwsS3Storage.so) ))

    if [[ $dl != 0 ]]; then

        export DEBIAN_FRONTEND=noninteractive && apt-get --assume-yes update && apt-get --assume-yes install libcrypto++-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

        cd $sourcesRootPath
        hg clone https://orthanc.uclouvain.be/hg/orthanc-object-storage/ -r $commitId

        pushd $buildRootPath

        cmake -DCMAKE_BUILD_TYPE:STRING=Release -DALLOW_DOWNLOADS=ON -DUSE_VCPKG_PACKAGES=OFF $sourcesRootPath/orthanc-object-storage/Aws/
        make -j 4

        upload libOrthancAwsS3Storage.so
    fi

elif [[ $target == "orthanc-google-storage" ]]; then

    dl=$(( $dl + $(download libOrthancGoogleCloudStorage.so) ))

    if [[ $dl != 0 ]]; then

        export DEBIAN_FRONTEND=noninteractive && apt-get --assume-yes update && apt-get --assume-yes install libcrypto++-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

        cd $sourcesRootPath
        hg clone https://orthanc.uclouvain.be/hg/orthanc-object-storage/ -r $commitId

        pushd $buildRootPath

        cmake -DCMAKE_BUILD_TYPE:STRING=Release -DALLOW_DOWNLOADS=ON -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake $sourcesRootPath/orthanc-object-storage/Google/
        make -j 4

        upload libOrthancGoogleCloudStorage.so
    fi


elif [[ $target == "orthanc-azure-storage" ]]; then

    dl=$(( $dl + $(download libOrthancAzureBlobStorage.so) ))

    if [[ $dl != 0 ]]; then

        export DEBIAN_FRONTEND=noninteractive && apt-get --assume-yes update && apt-get --assume-yes install libcrypto++-dev && apt-get clean && rm -rf /var/lib/apt/lists/*

        cd $sourcesRootPath
        hg clone https://orthanc.uclouvain.be/hg/orthanc-object-storage/ -r $commitId

        pushd $buildRootPath

        cmake -DCMAKE_BUILD_TYPE:STRING=Release -DALLOW_DOWNLOADS=ON -DCMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake $sourcesRootPath/orthanc-object-storage/Azure/
        make -j 4

        upload libOrthancAzureBlobStorage.so
    fi

elif [[ $target == "orthanc-webviewer" ]]; then

    dl=$(( $dl + $(download libOrthancWebViewer.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-webviewer/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4
        $buildRootPath/UnitTests

        upload libOrthancWebViewer.so
    fi

elif [[ $target == "orthanc-transfers" ]]; then

    dl=$(( $dl + $(download libOrthancTransfers.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-transfers/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4
        $buildRootPath/UnitTests

        upload libOrthancTransfers.so
    fi


elif [[ $target == "orthanc-dicomweb" ]]; then

    dl=$(( $dl + $(download libOrthancDicomWeb.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-dicomweb/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF $sourcesRootPath
        make -j 4
        $buildRootPath/UnitTests

        upload libOrthancDicomWeb.so
    fi

elif [[ $target == "orthanc-wsi" ]]; then

    dl=$(( $dl + $(download libOrthancWSI.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-wsi/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DUSE_SYSTEM_OPENJPEG=OFF $sourcesRootPath/ViewerPlugin
        make -j 4

        # TODO: build dicomizer tools ?

        upload libOrthancWSI.so

    fi

elif [[ $target == "orthanc-stone-wasm" ]]; then

    dl=$(( $dl + $(download stone.wasm.tar.gz) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-stone/ -r $commitId /source
        pushd /source/Applications/StoneWebViewer/WebAssembly
        chmod +x docker-internal.sh
        STONE_BRANCH=${commitId} ./docker-internal.sh Release

        mkdir -p $buildRootPath
        mkdir -p /target
        pushd /target
        tar -zcvf $buildRootPath/stone.wasm.tar.gz StoneWebViewer/

        upload stone.wasm.tar.gz

    else

        # since this is a multi-stage build, we must uncompress the tar.gz where the next step expects it (in /target)
        mkdir -p /target
        pushd /target
        tar xvf $buildRootPath/stone.wasm.tar.gz

    fi

elif [[ $target == "orthanc-stone-so" ]]; then

    dl=$(( $dl + $(download libStoneWebViewer.so) ))

    if [[ $dl != 0 ]]; then

        hg clone https://orthanc.uclouvain.be/hg/orthanc-stone/ -r $commitId $sourcesRootPath
        pushd $buildRootPath
        cmake -DALLOW_DOWNLOADS=ON -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_SYSTEM_GOOGLE_TEST=ON -DUSE_SYSTEM_ORTHANC_SDK=OFF -DORTHANC_STONE_BINARIES=/downloads/wasm-binaries/StoneWebViewer $sourcesRootPath/Applications/StoneWebViewer/Plugin/
        make -j 4

        upload libStoneWebViewer.so

    fi

fi

