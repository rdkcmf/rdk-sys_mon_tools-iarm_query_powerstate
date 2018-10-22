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
set -x

if [ -z $PLATFORM_SOC ]; then
    export PLATFORM_SOC=broadcom
fi

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

export USE_DBUS=y

SCRIPT=$(readlink -f "$0")
SCRIPTS_DIR=`dirname "$SCRIPT"`
export COMBINED_ROOT=$SCRIPTS_DIR/../..
export BUILDS_DIR=$SCRIPTS_DIR/../..
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
	if [ ${COMCAST_PLATFORM} = "rng150" ]; then
		echo "building for device type RNG 150..." 
    	export WORK_DIR=$BUILDS_DIR/workRNG150
        if [ -f $RDK_PROJECT_ROOT_PATH/sdk/scripts/setBcmEnv.sh ]; then
             source $RDK_PROJECT_ROOT_PATH/sdk/scripts/setBcmEnv.sh
        fi
        if [ -f $RDK_PROJECT_ROOT_PATH/sdk/scripts/setBCMenv.sh ]; then
             source $RDK_PROJECT_ROOT_PATH/sdk/scripts/setBCMenv.sh
        fi
		export OPENSOURCE_BASE=$BUILDS_DIR/opensource
		CROSS_COMPILE=mipsel-linux
		export CC=$CROSS_COMPILE-gcc
		export CXX=$CROSS_COMPILE-g++
		export GLIB_LIBRARY_PATH=$APPLIBS_TARGET_DIR/usr/local/lib/
		export GLIBS='-lglib-2.0 -lintl -lz'
		export COMBINED_ROOT=$BUILDS_DIR
	elif [ ${COMCAST_PLATFORM} = "xi3" ]; then
		export WORK_DIR=$COMBINED_ROOT/workXI3
		. $COMBINED_ROOT/build_scripts/setBCMenv.sh
		export OPENSOURCE_BASE=$BUILDS_DIR/opensource
		CROSS_COMPILE=mipsel-linux
		export CC=$CROSS_COMPILE-gcc
		export CXX=$CROSS_COMPILE-g++
		export GLIB_LIBRARY_PATH=$APPLIBS_TARGET_DIR/usr/local/lib/
		export GLIBS='-lglib-2.0 -lintl -lz'
	elif [ ${COMCAST_PLATFORM} = "xg1" ]; then
		export WORK_DIR=$COMBINED_ROOT/workXG1
		. $COMBINED_ROOT/build_scripts/setBCMenv.sh
		export OPENSOURCE_BASE=$BUILDS_DIR/opensource
		CROSS_COMPILE=mipsel-linux
		export CC=$CROSS_COMPILE-gcc
		export CXX=$CROSS_COMPILE-g++
		export GLIB_LIBRARY_PATH=$APPLIBS_TARGET_DIR/usr/local/lib/
		export GLIBS='-lglib-2.0 -lintl -lz'
	fi
elif [ $PLATFORM_SOC = "stm" ]; then 
	if [ ${COMCAST_PLATFORM} = "xi4" ]; then
		export TOOLCHAIN_DIR=$COMBINED_ROOT/sdk/toolchain/staging_dir
		#setup sdk environment variables
		export TOOLCHAIN_NAME=`find ${TOOLCHAIN_DIR} -name environment-setup-* | sed -r 's#.*environment-setup-##'`
		source $TOOLCHAIN_DIR/environment-setup-${TOOLCHAIN_NAME}
		export OPENSOURCE_BASE=$COMBINED_ROOT/opensource
		export GLIB_LIBRARY_PATH=$COMBINED_ROOT/sdk/fsroot/ramdisk/usr/local/lib
		export GLIB_CONFIG_INCLUDE_PATH=$TOOLCHAIN_DIR/sysroots/cortexa9t2hf-vfp-neon-oe-linux-gnueabi/usr/lib/glib-2.0/include
		export GLIBS='-lglib-2.0'
	fi
fi
make
if [ $? -ne 0 ] ; then
  echo QueryPower Tool  Build Failed
  exit 1
else
  echo QueryPower Tool  Build Success
  exit 0
fi
