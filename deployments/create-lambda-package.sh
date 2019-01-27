#!/bin/bash
set -e

FUNCTION_NAME=$1
PYTHON_VERSION=$2 # '3.6', '3.7', etc...
BUILD_DIR='build'
PACKAGE_DIR='package'

mkdir -p build # temporary directory for venv
mkdir -p package # source directory that will be zipped up by terraform

# source files
cp -r ./src/* ./${PACKAGE_DIR}

# pip packages
python${PYTHON_VERSION} -m venv ${BUILD_DIR}/${FUNCTION_NAME}
. ${BUILD_DIR}/${FUNCTION_NAME}/bin/activate
pip3 install  -r ./src/requirements.txt  -t ./${PACKAGE_DIR}
