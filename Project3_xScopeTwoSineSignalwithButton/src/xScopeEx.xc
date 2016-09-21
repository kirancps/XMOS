/*
 * xScopeEx.xc
 *
 *  Created on: May 22, 2015
 *      Author: KIRAN
 *
 *      This Program generates a sine wave. The sine wave can be seen in xscope display.
 *      A look up table for sine wave is created and called at regular interval.
 *      To view the sine signal, edit the config.xscope with the values :
 *      <Probe name="SIN_VALUE"  type="CONTINUOUS"  datatype="FLOAT"  units="Value" enabled="true"/>
 *      Set the run configuration to run the code on board, and under xscope tab, check real time.
 *      In the Makefile, add the line "XCC_FLAGS = -O2 -g -fxscope" under the XCC_FLAG section.
 *      The code generates two diffrent sine waves according to the buttons pressed.
 *      The same can be displayed on xscope on realtime
 */

#include <platform.h>
#include <xs1.h>
#include <xscope.h>
#include <timer.h>



in port button = XS1_PORT_4E;               //in port decleration

int main() {
    unsigned int p;
    unsigned int i;
    unsigned int output;
    unsigned int wait_time=1;               //wait time between samples
    const unsigned short sin_values[64] = { /* Sine look up table 64 sample, 6 bit each*/
      32,35,38,41,44,47,49,52,54,56,58,
      59,61,62,62,63,63,63,62,62,61,59,
      58,56,54,52,49,47,44,41,38,35,
      32,29,26,23,20,17,15,12,10,8,
      6,5,3,2,2,1,1,1,2,2,3,
      5,6,8,10,12,15,17,20,23,26,29};

 while (1)

     {
               button :> p;                 //reads button value XS1_PORT_4E
        for (i = 0; i < 64; i++)
        {

             if((p&0x1)==0){                //Reads switch SW1
                 delay_milliseconds(wait_time);
                 output= ( sin_values[i]);}
             else                           //Sets default sine value
                 {
                 delay_milliseconds(wait_time*2);
                 output= ( sin_values[i]);
                 }
                 xscope_float(SIN_VALUE, output); // Sends data to xscope for displaying on host
    }
  }
   return 0;
}

