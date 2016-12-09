#!/bin/bash
##########################################################################
# If not stated otherwise in this file or this component's Licenses.txt
# file the following copyright and licenses apply:
#
# Copyright 2016 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##########################################################################
#

#######################################
#
# Build Framework standard script for
#
# IARMBus component

# use -e to fail on any shell issue
# -e is the requirement from Build Framework
set -e


# default PATHs - use `man readlink` for more info
# the path to combined build
export RDK_PROJECT_ROOT_PATH=${RDK_PROJECT_ROOT_PATH-`readlink -m ..`}
export COMBINED_ROOT=$RDK_PROJECT_ROOT_PATH

# path to build script (this script)
export RDK_SCRIPTS_PATH=${RDK_SCRIPTS_PATH-`readlink -m $0 | xargs dirname`}

# path to components sources and target
export RDK_SOURCE_PATH=${RDK_SOURCE_PATH-`readlink -m .`}
export RDK_TARGET_PATH=${RDK_TARGET_PATH-$RDK_SOURCE_PATH}

# fsroot and toolchain (valid for all devices)
export RDK_FSROOT_PATH=${RDK_FSROOT_PATH-`readlink -m $RDK_PROJECT_ROOT_PATH/sdk/fsroot/ramdisk`}
export RDK_TOOLCHAIN_PATH=${RDK_TOOLCHAIN_PATH-`readlink -m $RDK_PROJECT_ROOT_PATH/sdk/toolchain/staging_dir`}


# default component name
export RDK_COMPONENT_NAME=${RDK_COMPONENT_NAME-`basename $RDK_SOURCE_PATH`}


# parse arguments
INITIAL_ARGS=$@

function usage()
{
    set +x
    echo "Usage: `basename $0` [-h|--help] [-v|--verbose] [action]"
    echo "    -h    --help                  : this help"
    echo "    -v    --verbose               : verbose output"
    echo
    echo "Supported actions:"
    echo "      configure, clean, build (DEFAULT), rebuild, install"
}

# options may be followed by one colon to indicate they have a required argument
if ! GETOPT=$(getopt -n "build.sh" -o hvp: -l help,verbose,platform: -- "$@")
then
    usage
    exit 1
fi

eval set -- "$GETOPT"

while true; do
  case "$1" in
    -h | --help ) usage; exit 0 ;;
    -v | --verbose ) set -x ;;
    -- ) shift; break;;
    * ) break;;
  esac
  shift
done

ARGS=$@


# component-specific vars
export RDK_PLATFORM_SOC=${RDK_PLATFORM_SOC-broadcom}
export PLATFORM_SOC=$RDK_PLATFORM_SOC
export CC_PLATFORM=${CC_PLATFORM-$RDK_PLATFORM_SOC}
CC_PATH=$RDK_SOURCE_PATH
export FSROOT=${RDK_FSROOT_PATH}
export TOOLCHAIN_DIR=${RDK_TOOLCHAIN_PATH}
export BUILDS_DIR=$RDK_PROJECT_ROOT_PATH



# functional modules

function configure()
{
    if [ $1 = "iarm" ] ; then
    export USE_IARM=y
    echo "Building for IARM Target..."
	elif [ $1 = "iarmbus" ] ; then
    export USE_IARM_BUS=y
    echo "Building for IARM Bus Target..."
	else
    export USE_IARM_BUS=y
    echo "Default...Building for IARM Bus Target..."
fi
}

function clean()
{
    true #use this function to provide instructions to clean workspace
}

function build()
{
    CURR_DIR=`pwd`
    if [ $PLATFORM_SOC = "intel" ]; then
	export TOOLCHAIN_DIR=$COMBINED_ROOT/sdk/toolchain/staging_dir
	export CROSS_TOOLCHAIN=$TOOLCHAIN_DIR
	export CROSS_COMPILE=$CROSS_TOOLCHAIN/bin/i686-cm-linux
	export CC=$CROSS_COMPILE-gcc
	export CXX=$CROSS_COMPILE-g++
	export OPENSOURCE_BASE=$COMBINED_ROOT/opensource
	export DFB_ROOT=$TOOLCHAIN_DIR 
	export DFB_LIB=$TOOLCHAIN_DIR/lib 
	export FUSION_PATH=$OPENSOURCE_BASE/src/FusionDale
	export FSROOT=$COMBINED_ROOT/sdk/fsroot/ramdisk
	export GLIB_LIBRARY_PATH=$CROSS_TOOLCHAIN/lib/
	export GLIB_CONFIG_INCLUDE_PATH=$GLIB_LIBRARY_PATH/glib-2.0/
	export GLIBS='-lglib-2.0'
elif [ $PLATFORM_SOC = "broadcom" ]; then 
	export WORK_DIR=$BUILDS_DIR/workXI3
	. $BUILDS_DIR/build_scripts/setBCMenv.sh
	export OPENSOURCE_BASE=$BUILDS_DIR/opensource
	CROSS_COMPILE=mipsel-linux
	export CC=$CROSS_COMPILE-gcc
	export CXX=$CROSS_COMPILE-g++
	export GLIB_LIBRARY_PATH=$APPLIBS_TARGET_DIR/usr/local/lib/
	export GLIBS='-lglib-2.0 -lintl -lz'
	export COMBINED_ROOT=$BUILDS_DIR
fi

    make

    cd $CURR_DIR

}

function rebuild()
{
    clean
    build
}

function install()
{
   true
}


# run the logic

#these args are what left untouched after parse_args
HIT=false

for i in "$ARGS"; do
    case $i in
        configure)  HIT=true; configure ;;
        clean)      HIT=true; clean ;;
        build)      HIT=true; build ;;
        rebuild)    HIT=true; rebuild ;;
        install)    HIT=true; install ;;
        *)
            #skip unknown
        ;;
    esac
done

# if not HIT do build by default
if ! $HIT; then
  build
fi
