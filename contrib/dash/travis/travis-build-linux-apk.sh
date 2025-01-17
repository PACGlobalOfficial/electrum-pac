#!/bin/bash
set -ev

if [[ -z $TRAVIS_TAG ]]; then
  echo TRAVIS_TAG unset, exiting
  exit 1
fi

BUILD_REPO_URL=https://github.com/PACGlobalOfficial/electrum-pac.git

cd build

git clone --branch $TRAVIS_TAG $BUILD_REPO_URL electrum-pac

pushd electrum-pac
./contrib/make_locale
find . -name '*.po' -delete
find . -name '*.pot' -delete
popd

sudo chown -R 1000 electrum-pac

DOCKER_CMD="rm -rf packages"
DOCKER_CMD="$DOCKER_CMD && ./contrib/make_packages"
DOCKER_CMD="$DOCKER_CMD && rm -rf packages/bls_py"
DOCKER_CMD="$DOCKER_CMD && rm -rf packages/python_bls*"
DOCKER_CMD="$DOCKER_CMD && ./contrib/make_apk"
if [ $ELECTRUM_MAINNET = false ] ; then
    DOCKER_CMD="$DOCKER_CMD release-testnet"
fi

docker run --rm \
    -v $(pwd)/electrum-pac:/home/buildozer/build \
    -t zebralucky/electrum-pac-winebuild:Kivy33x bash -c \
    "$DOCKER_CMD"
