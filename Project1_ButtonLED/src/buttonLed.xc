

/*This code reads on board push button and turns on LED in
 *sequential order. To get different color set diffent combination of RGB LED
 *
 *
 *
 * SW1 is used as input switch,
 * on board LED as output
 *
 * buttonLed.xc
 *
 *  Created on: May 19, 2015
 *      Author: KIRAN
 */


#include <platform.h>
#include <xs1.h>
#include <timer.h>
#include <stdio.h>



out port p = XS1_PORT_4F;                   // LED port
                                            //YELLOW: PORT_4F0(bit 0)
                                            //RED: PORT_4F1 (bit1); GREEN: PORT_4F2(bit2);  BLUE :PORT_4F3(bit3)
in port button = XS1_PORT_4E;               // on board switch  SW1:PORT_4E0   SW2: PORT_4E1


int main() {

   unsigned int x;

  while (1) {
      button :> x;                          //Read SW2 status

      if((x&0x2)==0)                        // negative logic: Button pressed,
      {
     p <: 0xa;                              //Turn LED on
     delay_milliseconds(200);
     p <: 0x2;
     delay_milliseconds(200);
     p <: 0x4;
     delay_milliseconds(200);
     p <: 0x8;
     delay_milliseconds(200);
     p <: 0x0;
      delay_milliseconds(200);
  }
  }
  return 0;
}






