/*PROJECT 0
 * blinkLed.xc
 *
 *  Created on: May 19, 2015
 *      Author: KIRAN
 *
 *      This code blinks all the onboard LED of xcore200 eXplorer kit.
 *      The led blinks sequentially one after other
 */


#include <platform.h>
#include <xs1.h>
#include <timer.h>                  //include this header file for delay_milliseconds function


port p = XS1_PORT_4F;
                                    //initialises the port for on board LED.
                                    //YELLOW: PORT_4F0(bit 0)
                                    //RED: PORT_4F1 (bit1); GREEN: PORT_4F2(bit2);  BLUE :PORT_4F3(bit3)                                    //LED are connected to 4 bit port, mask accordingly to
                                    // access the LED

int main() {
  while (1) {
     p <: 0x1;                      //yellow LED on
     delay_milliseconds(500);       //500ms delay
     p <: 0x2;                      //Blue LED on
     delay_milliseconds(500);
     p <: 0x4;                      //green LED on
     delay_milliseconds(500);
     p <: 0x8;                      //red LED on
     delay_milliseconds(500);
     p <: 0x0;                      // all LED off
      delay_milliseconds(500);
  }
  return 0;
}
