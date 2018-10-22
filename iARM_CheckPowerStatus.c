/*
 * If not stated otherwise in this file or this component's Licenses.txt file the
 * following copyright and licenses apply:
 *
 * Copyright 2016 RDK Management
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
*/
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define PADDING_SIZE 32
typedef enum _UIDev_PowerState_t {
    UIDEV_POWERSTATE_OFF,
    UIDEV_POWERSTATE_STANDBY,
    UIDEV_POWERSTATE_ON,
    UIDEV_POWERSTATE_UNKNOWN
} UIDev_PowerState_t;
    
typedef struct _UIMgr_Settings_t{
    unsigned int magic;
    unsigned int version;
    unsigned int length;
    UIDev_PowerState_t powerState;
    char padding[PADDING_SIZE];
} UIMgr_Settings_t ;


/**
 * Test application to check whether the box is in standby or not.
 * This has been developed to resolve, XONE-4598
 */
int main ()
{
    UIMgr_Settings_t uiSettings = {0};
    int ret = 0;
    const char *settingsFile = "/opt/uimgr_settings.bin";
    int fd = open(settingsFile, O_RDONLY);

    if (fd > 0) {
        lseek(fd, 0, SEEK_SET);
        ret = read(fd, &uiSettings, sizeof(uiSettings));
        if (ret == 0) {
            printf ("Unknown");
        }
        else if (ret > 0)
        {
            if (uiSettings.powerState == UIDEV_POWERSTATE_OFF)
                printf ("OFF");
            else if (uiSettings.powerState == UIDEV_POWERSTATE_STANDBY)
                printf ("STANDBY");
            else if (uiSettings.powerState == UIDEV_POWERSTATE_ON)
                printf ("ON");
        }
    }
    else
        printf ("Unknown");
    return 0;
}
