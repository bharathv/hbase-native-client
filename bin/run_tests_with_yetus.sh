#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -eo pipefail

if [[ "true" = "${DEBUG}" ]]; then
  set -x
  printenv
fi

SCRIPT_DIR=$(dirname $(realpath $0))
SRC_ROOT="$SCRIPT_DIR/.."
DEPS_DIR="$SRC_ROOT/dependencies"

# Create directory if it doesn't exist.
if [ ! -d $DEPS_DIR ]; then
  mkdir -p $DEPS_DIR
fi
YETUS_RELEASE=0.12.0
# Download Yetus if it isn't already there.
YETUS_HOME="$DEPS_DIR/apache-yetus-${YETUS_RELEASE}"
TESTPATCHBIN=$YETUS_HOME/bin/test-patch
TESTPATCHLIB=$YETUS_HOME/lib/precommit

pushd $DEPS_DIR > /dev/null
if [ ! -f $TESTPATCHBIN ]; then
  echo "Downloading Yetus...."
  curl -L --fail -O \
      "https://dist.apache.org/repos/dist/release/yetus/${YETUS_RELEASE}/apache-yetus-${YETUS_RELEASE}-bin.tar.gz"
  tar xzpf "apache-yetus-${YETUS_RELEASE}-bin.tar.gz"
fi
popd > /dev/null

if [[ "true" = "${DEBUG}" ]]; then
  # DEBUG print the test framework
  ls -l "${TESTPATCHBIN}"
  ls -la "${TESTPATCHLIB}/test-patch.d/"
  YETUS_ARGS=(--debug "${YETUS_ARGS[@]}")
fi

# Sanity checks for downloaded Yetus binaries.
if [ ! -x "${TESTPATCHBIN}" ]; then
  echo "Something is amiss with Yetus download."
  rm -rf "${YETUS_HOME}"
  exit 1
fi

# Runs in docker/non-docker mode. In docker mode, we pass the appropriate docker file with
# all the dependencies installed as a part of init.
if [[ "true" = "${RUN_IN_DOCKER}" ]]; then
  YETUS_ARGS=(
    --docker \
    "--dockerfile=${SRC_ROOT}/docker-files/Dockerfile" \
    "${YETUS_ARGS[@]}"
  )
fi

echo "Using YETUS_ARGS: ${YETUS_ARGS[*]}"

# shellcheck disable=SC2068
/bin/bash "${TESTPATCHBIN}" \
    --personality="${SRC_ROOT}/bin/hbase-native-client-personality.sh" \
    --run-tests \
    ${YETUS_ARGS[@]}
