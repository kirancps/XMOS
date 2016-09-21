/*
 * xScopeSim.xc
 * This code demonstrates the use of xSCOPE to display signals on PC in realtime
 * The code generates a sine wave using a look up table. One period of sine wave is
 * divided into 64 samples, each represeting 6 bit. Here a variable is assigned with the
 * sine value and checked at xscope. The same can be applied when these value are sent to
 * an 8 bit port. Connecting an external DAC will genearte analog sinewave.
 *
 * To view the signals on xscope, modify the makefile,add  XCC_FLAGS= -fxscope
 *
 * configure the config.xscope file, add probe name and set the data,
 *  for details check config.xscope file
 *  Created on: May 22, 2015
 *      Author: KIRAN
 */
#include <xscope.h>
#include <timer.h>

int main() {
    unsigned int i;
    unsigned int output;
    unsigned int wait_time=1;               //time interval between each sample
    const unsigned short sin_values[64] = { /* Sine wave look up table*/
      32,35,38,41,44,47,49,52,54,56,58,
      59,61,62,62,63,63,63,62,62,61,59,
      58,56,54,52,49,47,44,41,38,35,
      32,29,26,23,20,17,15,12,10,8,
      6,5,3,2,2,1,1,1,2,2,3,
      5,6,8,10,12,15,17,20,23,26,29};

   while (1)
       {

        for (i = 0; i < 64; i++)
        {
            delay_milliseconds(wait_time);      //waits for one sample time (1ms) between two values
            output= ( sin_values[i]);
            xscope_float(SIN_VALUE, output);    //connects to PC and sends the observed data at output
    }
  }

return 0;
}
