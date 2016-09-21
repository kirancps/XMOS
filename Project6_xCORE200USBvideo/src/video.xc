/*
 * video.xc
 *
 *  Created on: Jun 2, 2015
 *      Author: KIRAN
 */

#include <platform.h>
#include <xs1.h>
#include <xscope.h>
#include <xccompat.h>

#include "usb_video.h"

/* xSCOPE Setup Function */
#if (USE_XSCOPE == 1)
void xscope_user_init(void) {
    xscope_register(0, 0, "", 0, "");
    xscope_config_io(XSCOPE_IO_BASIC); /* Enable fast printing over XTAG */
}
#endif

/* USB Endpoint Defines */
#define XUD_EP_COUNT_OUT   1    // 1 OUT EP0
#define XUD_EP_COUNT_IN    3    // (1 IN EP0 + 1 INTERRUPT IN EP + 1 ISO IN EP)

int main() {

    chan c_ep_out[XUD_EP_COUNT_OUT], c_ep_in[XUD_EP_COUNT_IN];

    /* 'Par' statement to run the following tasks in parallel */
    par
    {
        on USB_TILE: xud(c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
                         null, XUD_SPEED_HS, XUD_PWR_SELF);

        on USB_TILE: Endpoint0(c_ep_out[0], c_ep_in[0]);

        on USB_TILE: VideoEndpointsHandler(c_ep_in[1], c_ep_in[2]);
    }
    return 0;
}
