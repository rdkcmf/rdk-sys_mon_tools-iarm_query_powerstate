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
SUBDIRS =
DIST_SUBDIRS =

# the list of header files that belong to the library (to be installed later)
AM_CFLAGS = $(DBUS_CFLAGS) $(DIRECT_CFLAGS) $(FUSION_CFLAGS) $(GLIB_CFLAGS) \
	    -I$(PKG_CONFIG_SYSROOT_DIR)${includedir}/rdk/iarmbus \
	    -I$(PKG_CONFIG_SYSROOT_DIR)${includedir}/rdk/iarmmgrs/power \
	    -I$(PKG_CONFIG_SYSROOT_DIR)${includedir}/rdk/iarmmgrs-hal

bin_PROGRAMS = QueryPowerState

QueryPowerState_SOURCES=IARM_Bus_CheckPowerStatus.c
QueryPowerState_LDADD = $(DIRECT_LIBS) $(FUSION_LIBS) $(GLIB_LIBS) -lIARMBus $(DBUS_LIBS)

## IPK generation Support
iarm_query_powerstate_IPK_OUTDIR = $(abs_top_builddir)/ipk
iarm_query_powerstate_IPK_STAGING_DIR=$(abs_top_builddir)/staging_dir
iarm_query_powerstate_IPK_TMP_DIR=$(iarm_query_powerstate_IPK_STAGING_DIR)/ipk

iarm_query_powerstate_CONTROL_FILES = control
iarm_query_powerstate_IPK_FILES  = debian-binary control.tar.gz data.tar.gz
iarm_query_powerstate_IPK_OUTPUT = iarm-query-powerstate.ipk

WRKDIR          =       .
SYS_USR_DIR     =       /usr

package_ipk:
	echo "Generating IPK Package"
	install -d $(iarm_query_powerstate_IPK_STAGING_DIR)$(SYS_USR_DIR)/bin
	install -m 0755 $(WRKDIR)/QueryPowerState $(iarm_query_powerstate_IPK_STAGING_DIR)$(SYS_USR_DIR)/bin
	cd $(iarm_query_powerstate_IPK_STAGING_DIR)$(SYS_USR_DIR) && ln -sf /usr/bin/QueryPowerState $(iarm_query_powerstate_IPK_STAGING_DIR) && cd -
	tar -czvf $(iarm_query_powerstate_IPK_OUTDIR)/data.tar.gz -C $(iarm_query_powerstate_IPK_STAGING_DIR) .
	tar -czvf $(iarm_query_powerstate_IPK_OUTDIR)/control.tar.gz -C $(iarm_query_powerstate_IPK_OUTDIR) $(iarm_query_powerstate_CONTROL_FILES)
	cd $(iarm_query_powerstate_IPK_OUTDIR) && ar cr $(iarm_query_powerstate_IPK_OUTPUT) $(iarm_query_powerstate_IPK_FILES) && cd -
	rm -rf $(iarm_query_powerstate_IPK_STAGING_DIR)
